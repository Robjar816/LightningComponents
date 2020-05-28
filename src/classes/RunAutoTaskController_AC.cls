/*********************************************************************
Class Name: RunAutoTaskController_AC
Created By: MST - Robert Jaramillo 
Created On: 04-02-2020
Description: Controller for RunAutoTask lightning component.
*********************************************************************/
public class RunAutoTaskController_AC {

    @AuraEnabled
    public Boolean hasError; //Used to verify any exception occurred
    
    @AuraEnabled
    public String errorMessage; //Used to hold the exception message
    
    @AuraEnabled
    public String userMessage; //Used to hold the custom error message
    
    @AuraEnabled
    public Map<String, String> autoTaskMap; //Used to store controlling field values.
    
    @AuraEnabled
    public Map<String, String> taskMap;
    
    @AuraEnabled
    public Task taskToUpdate;
        
    @AuraEnabled
    public RunAutoTaskController_AC controller;
    
    @AuraEnabled
    public static RunAutoTaskController_AC getAutoTasks(String caseRecordId) {
        
        RunAutoTaskController_AC controller = new RunAutoTaskController_AC();
        controller.autoTaskMap = new Map<String, String>();
        controller.taskMap = getRelatedTasks(caseRecordId);

        for(Auto_Task__c autoTaskRecord : [SELECT Id, Name FROM Auto_Task__c ORDER BY Name ASC LIMIT 300]) {
            controller.autoTaskMap.put(autoTaskRecord.Name, autoTaskRecord.Id);
        }
        return controller;
    }
    
    @AuraEnabled
    public static RunAutoTaskController_AC getTaskAndRunAutoTask(String caseRecordId, String autoTaskSelectedId, String taskToUpdateSelected) {
        //Task to update
        Task taskRecord;
        if(String.isNotBlank(taskToUpdateSelected)) {
            List<Task> taskRecordList = [SELECT Id FROM Task WHERE WhatId =: caseRecordId AND Id =: taskToUpdateSelected ORDER BY CreatedDate DESC LIMIT 1];
            taskRecord = taskRecordList[0];
        }else {
            taskRecord = null;
        }
        
        //Get Auto Task by name
        if(String.isNotBlank(autoTaskSelectedId)) {
            return runAutoTasks(caseRecordId, autoTaskSelectedId, taskRecord, true);
        }else {
            return null;
        }
    }

    @AuraEnabled
    public static RunAutoTaskController_AC runAutoTasks(String caseRecordId, String autoTaskRecordId, Task taskRecord, Boolean updateTask) {
        
        Savepoint sp = Database.setSavepoint();

        Map<String, List<Action__c>> objectUpdateActionMap = new Map<String, List<Action__c>>();
        List<Action__c> updateActionList = new List<Action__c>();
        List<Action__c> sendEmailActionList = new List<Action__c>();
        List<Action__c> sendSurveyActionList = new List<Action__c>();        
        RunAutoTaskController_AC controller = new RunAutoTaskController_AC();
        Boolean isSuccessful = true;
        
        try{
            
            //Get record type id's
            String updateFieldRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.UPDATE_FIELD_RT).getRecordTypeId();
            String sendEmailRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.SEND_EMAIL_RT).getRecordTypeId();
            String sendSurveyRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.SEND_SURVEY_RT).getRecordTypeId();
            
            //Get Actions related to Auto Task and insert to map. Key=Object, Value=List<Action__c>
            for(Action__c action : [SELECT Id, Name, RecordTypeId, Field_To_Update__c, Field_To_Update_API_Name__c, New_Value__c, Object__c, 
                                    Template_Name__c, Send_Email_To__c, Recipient_s_Email_Address__c, Survey_Name__c, Send_Survey_To__c, Send_Email_From__c
                                    FROM Action__c Where Auto_Task__c =: autoTaskRecordId]) {
                //Update field Case Actions
                if(action.RecordTypeId == updateFieldRecordTypeId && action.Object__c == 'Case'){
                    if(objectUpdateActionMap.containsKey(action.Object__c)) {
                        objectUpdateActionMap.get(action.Object__c).add(action);
                    }else {
                        objectUpdateActionMap.put(action.Object__c, new List<Action__c> {action});
                    }
                }
                //Update field Task Actions
                else if(action.RecordTypeId == updateFieldRecordTypeId && action.Object__c == 'Task') {
                    if(objectUpdateActionMap.containsKey(action.Object__c)) {
                        objectUpdateActionMap.get(action.Object__c).add(action);
                    }else {
                        objectUpdateActionMap.put(action.Object__c, new List<Action__c> {action});
                    }
                }
                //Send Email Actions
                else if(action.RecordTypeId == sendEmailRecordTypeId) {
                    sendEmailActionList.add(action);
                }
                //Send Survey Actions
                else if(action.RecordTypeId == sendSurveyRecordTypeId) {
                    sendSurveyActionList.add(action);
                }
            }
          
            //Get Case from where Run Auto Task was invoked
            Case caseRecord = [SELECT Id, ContactEmail, ContactId, User_Email__c, Owner.Email, ROAE_Email__c, CreatedById, 
                               Account.Primary_Email__pc, ROAE_Closed_By__c FROM Case WHERE Id =: caseRecordId LIMIT 1];
            
            //Update case record
            if(objectUpdateActionMap.containsKey('Case') && caseRecord != null) {
                List<Action__c> caseActions = objectUpdateActionMap.get('Case');
                queryAndUpdateRecord(caseActions, caseRecord, 'Case', true);
            }
            //Update task record
            if(objectUpdateActionMap.containsKey('Task') && taskRecord !=  null) {
                List<Action__c> taskActions = objectUpdateActionMap.get('Task');
                queryAndUpdateRecord(taskActions, taskRecord, 'Task', updateTask);
            }
            //Send emails
            for(Action__c actionRecord : sendEmailActionList) {
                sendEmail(caseRecord, actionRecord);
            }
            
            //Send survey if case has been closed and send survey actions exist
            if(!sendSurveyActionList.isEmpty() && String.isNotEmpty(caseRecord.ROAE_Closed_By__c)) {
                CaseTriggerHandler_AC c = new CaseTriggerHandler_AC();
                Map<String,Task> mapOfCaseToTask = new Map<String,Task>();
                List<Case> caseList = new List<Case>();
                
                caseList.add(caseRecord);
                mapOfCaseToTask = c.getTask(caseList);
                
                //Get user who closed case
                List<User> caseClosedBy = [SELECT Id, Managing_Director__c, ManagerId FROM User WHERE Id =: caseRecord.ROAE_Closed_By__c LIMIT 1];
                
                //Send Survey
                for(Action__c actionRecord : sendSurveyActionList) {
                    String userMessage = sendSurvey(caseRecord, actionRecord,mapOfCaseToTask, caseClosedBy[0]);
                    if(userMessage != 'SUCCESS') {
                        isSuccessful = false;
                        controller.userMessage = userMessage;
                    }
                }
            }
            
            
            //If something failed roll everything back
            if(!isSuccessful) {
                Database.rollback(sp);
            }
        }catch(Exception e) {
            controller.hasError = true;
            controller.errorMessage = 'Exception: ' + e.getMessage();
            ApplicationLogs__c appLog = new ApplicationLogs__c(Event_Type__c = 'RUN_AUTO_TASK' , Class_Name__c = 'RunAutoTaskController_AC', 
                                                               Error_Message__c = e.getMessage(), StackTrace__c	= e.getStackTraceString(), 
                                                               Line_Number__c = String.valueOf(e.getLineNumber()));
            insert appLog;
            Database.rollback(sp);
        }
        return controller;
    }
    
    @TestVisible //Update record according to action
    private static void queryAndUpdateRecord(List<Action__c> actionList, sObject recToUpdate, String objectName, Boolean updateRecord) {
        Map<String, Schema.SObjectField> fieldMap = CreateActionController_AC.getSchema(objectName);
       
        if(updateRecord){
            String query = 'SELECT Id';
            for(Action__c actionRecord : actionList) {
                if(String.isNotBlank(actionRecord.Field_To_Update_API_Name__c)) {
                    query += ', ' + actionRecord.Field_To_Update_API_Name__c;
                }
            }
            
            query += ' FROM ' + objectName + ' ' + 'WHERE Id = \'' + recToUpdate.Id +'\'';
            recToUpdate = Database.query(query);
            
            for(Action__c actionRecord : actionList) {
                if(String.isNotBlank(actionRecord.Field_To_Update_API_Name__c)) {
                    //If field type is Boolean, convert String to Boolean
                    if(fieldMap.get(actionRecord.Field_To_Update_API_Name__c).getDescribe().getType() == Schema.DisplayType.BOOLEAN) {
                        recToUpdate.put(actionRecord.Field_To_Update_API_Name__c, Boolean.valueOf(actionRecord.New_Value__c)); 
                    }else {
                        recToUpdate.put(actionRecord.Field_To_Update_API_Name__c, actionRecord.New_Value__c);  
                    }
                }
            }
            update recToUpdate;
            System.debug('recToUpdate after update *** = ' + recToUpdate);
        }else { //Will only be invoked when user creates task through template and it has a related auto task
            for(Action__c actionRecord : actionList) {
                if(String.isNotBlank(actionRecord.Field_To_Update_API_Name__c)) {
                    recToUpdate.put(actionRecord.Field_To_Update_API_Name__c, actionRecord.New_Value__c);                
                }
            }
        }
    }
    
    //Send email message
    private static void sendEmail(Case parentCase, Action__c actionRecord) {
        
        //Query for template
        List<EmailTemplate> emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body, IsActive
                                       FROM EmailTemplate WHERE name =: actionRecord.Template_Name__c Limit 1];
        
        //Query for org wide email address
        OrgWideEmailAddress owea = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName =: actionRecord.Send_Email_From__c LIMIT 1];
        
        //Get email recipients' email address
        List<String> toAddresses = getRecipientEmail(parentCase, actionRecord);
        
        String contactId;
        if(parentCase.ContactId != null) {
            contactId = parentCase.ContactId;
        } else {
            contactId = [SELECT Id From Contact LIMIT 1].Id;
        }
        
        //Create email message
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(contactId); 
        message.setOrgWideEmailAddressId(owea.Id);
        message.setSaveAsActivity(false); 
        message.setTemplateID(emailTemplate[0].Id); 
        message.setWhatId(parentCase.Id); //This is important for the merge fields in template to work
        message.toAddresses = toAddresses;
        message.setTreatTargetObjectAsRecipient(false);
        
        //Send email message
        if(emailTemplate[0] != null && emailTemplate[0].IsActive && !toAddresses.isEmpty()) {
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
                EmailMessage newMessage = new EmailMessage();
                newMessage.Status = '3';
                newMessage.ParentId = parentCase.Id;
                newMessage.RelatedToId = parentCase.Id;
                newMessage.EmailTemplateId = emailTemplate[0].Id;
                newMessage.MessageDate = System.now();
                newMessage.htmlBody = emailTemplate[0].HtmlValue;
                newMessage.TextBody = emailTemplate[0].Body;
                newMessage.Subject = 'Auto Task - ' + message.getSubject();
                newMessage.FromName = owea.DisplayName;
                newMessage.FromAddress = owea.Address;
                if(toAddresses.size() > 1) {
                    String emailListToString;
                    for(String email : toAddresses){
                        emailListToString =+ email + ', ';
                    }
                    newMessage.ToAddress = emailListToString.removeEnd(', ');
                }else {
                    newMessage.ToAddress = toAddresses[0];
                }
                insert newMessage;

            } else {
                System.debug('The email failed to send: ' +  results[0].errors[0].message);
                ApplicationLogs__c appLog = new ApplicationLogs__c(Event_Type__c = 'SEND_EMAIL_AUTO_TASK' , Class_Name__c = 'RunAutoTaskController_AC', 
                                                                   Error_Message__c = 'The email failed to send: ' +  results[0].errors[0].message);
                insert appLog;
            }
        }else {
            ApplicationLogs__c appLog = new ApplicationLogs__c(Event_Type__c = 'SEND_EMAIL_AUTO_TASK' , Class_Name__c = 'RunAutoTaskController_AC', 
                                                               Error_Message__c = 'Did not send email for one of the following reasons: \n' +
                                                               ' 1) Template either does not exist or is not active' +
                                                               ' 2) Send To email not found.');
            insert appLog;
        }
    }
    
    //Get recipient email address
    private static List<String> getRecipientEmail(Case caseRecord, Action__c actionRecord) {
        List<String> emails = new List<String>();
        
        if(actionRecord.Send_Email_To__c == 'Case Creator' && String.isNotBlank(caseRecord.User_Email__c)) {
            emails.add(caseRecord.User_Email__c);
        }else if(actionRecord.Send_Email_To__c == 'Case Owner' && String.isNotBlank(caseRecord.Owner.Email)) {
            emails.add(caseRecord.Owner.Email);
        }else if(actionRecord.Send_Email_To__c == 'Student' && String.isNotBlank(caseRecord.Account.Primary_Email__pc)) {
            emails.add(caseRecord.Account.Primary_Email__pc);
        }else if(actionRecord.Send_Email_To__c == 'Other' && String.isNotBlank(actionRecord.Recipient_s_Email_Address__c)) {
            for(String email : actionRecord.Recipient_s_Email_Address__c.split(';')) {
                emails.add(email);
            }
        }
        return emails;
    }
    
    //Get all tasks that are not closed to display on drop down
    private static Map<String, String> getRelatedTasks(String caseRecordId) {
        Map<String, String> taskMap = new Map<String, String>();
        Set<String> closedStatusValueSet = new Set<String>();
        
        //Add "Closed" Status values to a set from Custom Metadata Type record
        for (Required_Fields_on_Task__mdt currentSetting : [SELECT Label, FieldSet__c FROM Required_Fields_on_Task__mdt WHERE Label = 'ROAE Closed Status Values' LIMIT 1]) {
            if(!String.isBlank(currentSetting.FieldSet__c) && currentSetting.FieldSet__c.split(';') != null){
                for(String fieldName : currentSetting.FieldSet__c.split(';')){
                    closedStatusValueSet.add(fieldName);
                }
            }
        }
        
        String recordType = System.Label.Task_RO_OAE_RT;
        String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        //Tasks that are not in closed status value. Status values considered closed are declared in custom metadata type.
        List<Task> tasksNotClosed = [SELECT Id, WhatId, Subject FROM Task 
                                     WHERE WhatId =: caseRecordId AND Status NOT IN : closedStatusValueSet 
                                     AND RecordTypeId =: taskRecordTypeId];
        
        for(Task taskRecord : tasksNotClosed) {
            taskMap.put(taskRecord.Subject, taskRecord.Id);
        }
        return taskMap;
    }
    
    //Create a Survey Stage record to send auto task survey
    private static String sendSurvey(Case caseRecord, Action__c actionRecord, Map<String,Task> mapCaseToTask, User caseClosedBy) {
        
        String userMessage;
        if(!Test.isRunningTest()) {
            userMessage = doesSurveyExist(actionRecord);
        }
        
        if(String.isBlank(userMessage)) {
            String emailToSendSurvey = getSurveyRecipientEmail(caseRecord, actionRecord);
            if(String.isNotBlank(emailToSendSurvey) && caseRecord != null) {
                Survey__c newSurvey = new Survey__c();
                newSurvey.ROAE_Case__c = caseRecord.Id;
                newSurvey.ROAE_Case_Created_By__c = caseRecord.CreatedById;
                newSurvey.ROAE_Case_Closed_By__c = caseRecord.ROAE_Closed_By__c;
                newSurvey.ROAE_Auto_Task__c = true;
                newSurvey.EMAIL_ADDRESS__c = emailToSendSurvey;
                newSurvey.TRIGGER_NAME__c = actionRecord.Survey_Name__c;
                newSurvey.STAGING_STATUS__c = 'Open';
                newSurvey.STAGING_STATUS_DATETIME__c = Datetime.now();
                
                //Added as a part of 1056 : Sahil
            if((mapCaseToTask.get(caseRecord.id)) != null){
                newSurvey.RO_OAE_Assignment_Group__c =(mapCaseToTask.get(caseRecord.id)).ROAE_Assignment_Group__c;
                newSurvey.RO_OAE_Task_Closed_By__c =mapCaseToTask.get(caseRecord.id).lastModifiedBy.Name;
                newSurvey.RO_OAE_Task_Type__c =(mapCaseToTask.get(caseRecord.id)).ROAE_Task_Type__c;
                newSurvey.ROOAE_Task_Assigned_To__c = (mapCaseToTask.get(caseRecord.id)).Owner.Name;
            }
                if(caseClosedBy != null) {
                    newSurvey.OwnerId = caseClosedBy.Id;
                    if(String.isNotBlank(caseClosedBy.ManagerId)){
                        newSurvey.ROAE_Manager__c = caseClosedBy.ManagerId;
                    }
                    if(String.isNotBlank(caseClosedBy.Managing_Director__c)){
                        newSurvey.ROAE_Director__c = caseClosedBy.Managing_Director__c;
                    }
                }
                Database.SaveResult result = Database.insert(newSurvey, false);
                //insert newSurvey;
                
                userMessage = getUserMessage(result, 'Survey Stage');
            }else {
                if(String.isBlank(actionRecord.Send_Survey_To__c)){
                    userMessage = 'Failed to send survey: "Send Suvey To" on Action Record is not populated.';
                }else {
                     userMessage = 'Failed to send survey: ' + actionRecord.Send_Survey_To__c + '\'s email address is missing.';
                }
            }
        }
        return userMessage;
    }
    
    @TestVisible //To determine if template exists
    private static String doesSurveyExist(Action__c actionRecord) {
        String userMessage;
        List<Survey> surveyList = [SELECT Id FROM Survey WHERE Name =: actionRecord.Survey_Name__c];
        if(surveyList.size() < 1) {
            userMessage = 'Survey "' + actionRecord.Survey_Name__c + '" was not found.';
        }
        else if(surveyList.size() > 1) {
            userMessage = 'More than one survey with the same name exist';
        }
        return userMessage;
	}
    
    //Get recipient email address
    private static String getSurveyRecipientEmail(Case caseRecord, Action__c actionRecord) {
        String emailAddress = null;
        List<String> emails = new List<String>();
        
        if(actionRecord.Send_Survey_To__c == 'Case Creator' && String.isNotBlank(caseRecord.User_Email__c)) {
            emailAddress = caseRecord.User_Email__c;
        }else if(actionRecord.Send_Survey_To__c == 'Student' && String.isNotBlank(caseRecord.Account.Primary_Email__pc)) {
            emailAddress = caseRecord.Account.Primary_Email__pc;
        }else if(actionRecord.Send_Survey_To__c == 'Other' && String.isNotBlank(actionRecord.Recipient_s_Email_Address__c)) {
            for(String email : actionRecord.Recipient_s_Email_Address__c.split(';')) {
                emails.add(email);
            }
            if(!emails.isEmpty()) {
                emailAddress = emails[0];
            }
        }
        return emailAddress;
    }
    
    //Get user message
    private static String getUserMessage(Database.SaveResult result, String recBeingInsert) {
        String userMessage;
        if(result.isSuccess()){
            userMessage = 'SUCCESS';
        }else {
            for(Database.Error err : result.getErrors()) {
                userMessage = recBeingInsert + ': ' + err.getMessage() + '\n';
            }
        }
        return userMessage;
    }
}