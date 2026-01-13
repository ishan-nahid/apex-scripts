// Base URL using Named Credential + Company Realm ID
String baseUrl = 'callout:QB_Named_Credential/v3/company/' + String.valueOf(System.Label.realmId);

// Correct SOQL query - use AcctNum (NOT AccountNumber)
String query = 'SELECT Id, Name, AcctNum FROM Account WHERE Active = true';

// Build the query endpoint
String queryUrl = '/query?query=' + EncodingUtil.urlEncode(query, 'UTF-8');
String endpoint = baseUrl + queryUrl;

// Prepare the HTTP request
HttpRequest req = new HttpRequest();
req.setMethod('GET');
req.setEndpoint(endpoint);
req.setHeader('Accept', 'application/json');
req.setTimeout(120000);

// Send request
Http http = new Http();
HttpResponse res = http.send(req);

// Process response
if (res.getStatusCode() == 200) {
    // Parse JSON response
    Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
    Map<String, Object> queryResponse = (Map<String, Object>) body.get('QueryResponse');
    
    if (queryResponse != null && queryResponse.containsKey('Account')) {
        List<Object> accounts = (List<Object>) queryResponse.get('Account');
        
        if (accounts.isEmpty()) {
            System.debug('No active accounts found with AcctNum');
        }
        
        // Process each account
        for (Object accountObj : accounts) {
            Map<String, Object> account = (Map<String, Object>) accountObj;
            
            String accountId   = (String) account.get('Id');
            String accountName = (String) account.get('Name');
            String acctNum     = (String) account.get('AcctNum');
            
            // Skip accounts without an account number
            if (String.isBlank(acctNum)) {
                continue;
            }
            
            // Output / log the results
            System.debug('----------------------------------------');
            System.debug('Account ID:       ' + accountId);
            System.debug('Account Name:     ' + accountName);
            System.debug('Account Number:   ' + acctNum);
            System.debug('----------------------------------------');
        }
    } else {
        System.debug('No "Account" key found in QueryResponse');
        System.debug('Full response: ' + res.getBody());
    }
} else {
    // Error handling
    System.debug('API Error ' + res.getStatusCode() + ' - ' + res.getStatus());
    System.debug('Response Body: ' + res.getBody());
    System.debug('Endpoint used: ' + endpoint);
}
