// === Anonymous Apex - Sync QBO Accounts to GiftDesignation (batched callouts) ===

String baseUrl = 'callout:QB_Named_Credential/v3/company/' + String.valueOf(System.Label.realmId);
Http http = new Http();

List<GiftDesignation> designations = [
    SELECT Id, Name, QuickBooks_Account_Number__c, QuickBooks_Account_Id__c
    FROM GiftDesignation
    WHERE Name != null
    LIMIT 90          // safe under callout limit
];

Integer calloutCount = 0;
Integer created = 0;
Integer updated = 0;
List<GiftDesignation> toUpdate = new List<GiftDesignation>();

Map<String, String> nameToQboId = new Map<String, String>();

// First: check existing accounts (1 callout)
String query = 'SELECT Id, Name FROM Account WHERE Active = true';
String encoded = EncodingUtil.urlEncode(query, 'UTF-8');
HttpRequest req = new HttpRequest();
req.setEndpoint(baseUrl + '/query?query=' + encoded);
req.setMethod('GET');
req.setHeader('Accept', 'application/json');
req.setTimeout(120000);

HttpResponse res = http.send(req);
calloutCount++;

if (res.getStatusCode() == 200) {
    Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
    Map<String, Object> qr = (Map<String, Object>) body.get('QueryResponse');
    if (qr != null && qr.containsKey('Account')) {
        for (Object accObj : (List<Object>) qr.get('Account')) {
            Map<String, Object> acc = (Map<String, Object>) accObj;
            String name = (String) acc.get('Name');
            if (String.isNotBlank(name)) {
                nameToQboId.put(name, (String) acc.get('Id'));
            }
        }
    }
}

for (GiftDesignation gd : designations) {
    String name = gd.Name;

    if (nameToQboId.containsKey(name)) {
        String qboId = nameToQboId.get(name);
        if (gd.QuickBooks_Account_Id__c != qboId) {
            gd.QuickBooks_Account_Id__c = qboId;
            toUpdate.add(gd);
            updated++;
        }
    } else if (calloutCount < 100) {
        // Create
        Map<String, Object> payload = new Map<String, Object>{
            'Name' => name,
            'AccountType' => 'Income',
            'AccountSubType' => 'NonProfitIncome',
            'AcctNum' => gd.QuickBooks_Account_Number__c
        };

        HttpRequest createReq = new HttpRequest();
        createReq.setEndpoint(baseUrl + '/account');
        createReq.setMethod('POST');
        createReq.setHeader('Content-Type', 'application/json');
        createReq.setHeader('Accept', 'application/json');
        createReq.setBody(JSON.serialize(payload));

        HttpResponse createRes = http.send(createReq);
        calloutCount++;

        if (createRes.getStatusCode() >= 200 && createRes.getStatusCode() < 300) {
            Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(createRes.getBody());
            String newId = (String) ((Map<String, Object>) resp.get('Account')).get('Id');
            gd.QuickBooks_Account_Id__c = newId;
            toUpdate.add(gd);
            nameToQboId.put(name, newId);
            created++;
        }
    }
}

if (!toUpdate.isEmpty()) {
    update toUpdate;
}

System.debug('Callouts used: ' + calloutCount);
System.debug('Updated: ' + updated + ' | Created: ' + created);
