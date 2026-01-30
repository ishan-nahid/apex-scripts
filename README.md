
# Form Editor Salesforce Application

## Overview
This application allows admins to create and manage custom forms within Salesforce. Admins can configure form templates, including field types, dependencies, and versioning. End users can then submit data through these forms, which is saved into Salesforce.

## Features
- **Form Creation:** Admins can create new forms, configure field types (e.g., text, picklist), and set up dependencies between fields.
- **Field Dependencies:** Form fields can be dynamically shown or hidden based on other field selections.
- **Form Preview:** Admins and users can preview forms before submission.
- **Form Submission:** Submitted form data is saved as `Form_Submission__c` records in Salesforce.

## Components
- **FormEditorController.cls:** Manages form templates and field configurations.
- **FormController.cls:** Handles form data saving and retrieval.
- **LWC Components:**
  - **formEditor:** Interface for creating and editing form templates.
  - **formPreviewer:** Allows users to preview the form and its fields.

## Installation
1. Clone the repository to your Salesforce org.
2. Deploy the classes and Lightning Web Components (LWC).
3. Add the `Form__c` and `Form_Submission__c` objects in your org.

## Usage
1. Create a new form template by selecting the object and configuring its fields.
2. Preview and adjust the form as needed.
3. Save the form and make it available for end users.
4. Users can submit the form, and data will be saved as a `Form_Submission__c` record.

## License
MIT License
