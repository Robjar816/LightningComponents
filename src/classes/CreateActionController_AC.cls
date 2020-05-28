/*********************************************************************
Class Name: CreateActionController_AC 
Created By: MST - Robert Jaramillo 
Created On: 04-02-2020
Description: Controller for CreateAction lightning component.
*********************************************************************/
public class CreateActionController_AC {

    @AuraEnabled
    public Boolean hasError; //Used to verify any exception occurred
    
    @AuraEnabled
    public String errorMessage; //Used to hold the exception message
    
    @AuraEnabled
    public String userMessage; //Used to hold the custom error message
    
    @AuraEnabled
    public Action__c actionRecord; //Used to display action record being viewed/edited
    
    @AuraEnabled
    public Map<String, Map<String, String>> fieldMap; //Used to store layout field values.
    
    @AuraEnabled
    public List<String> orgWideEmails; //Used to store organization wide email addresses.
    
    @AuraEnabled
    public Map<String, List<String>> layoutMap; //Used to store layouts.
    
    @AuraEnabled
    public Map<String, String> caseQueueMap;
    
    @AuraEnabled
    public Map<String, String> taskQueueMap;
        
    @AuraEnabled
    public CreateActionController_AC controller;
    
    @AuraEnabled
    public static CreateActionController_AC getCaseFields(String actionRecId) {
        
        List<String> fieldList = new List<String>();
        CreateActionController_AC controller = new CreateActionController_AC();
        controller.fieldMap = new Map<String, Map<String, String>>();
        controller.layoutMap = new Map<String, List<String>>();
        controller.caseQueueMap = new Map<String, String>();
        controller.taskQueueMap = new Map<String, String>();
        
        try{            
            for(Layouts_On_New_Action__mdt layout : [SELECT Label, Object__c FROM Layouts_On_New_Action__mdt ORDER BY Label ASC]) {
                String layoutName = layout.Object__c + '-' + layout.Label;
                controller.fieldMap.put(layoutName,getFieldsFromLayout(layout.Object__c, layoutName));
                //Populating map with all layouts in  custom medata type record
                if(controller.layoutMap.containsKey(layout.Object__c)) {
                    controller.layoutMap.get(layout.Object__c).add(layout.Label);
                }else {
                    controller.layoutMap.put(layout.Object__c, new List<String>{layout.Label});
                }
            }
            
            //Get all fields from layouts
            //controller.fieldMap.put('Case',getFieldsFromLayout('Case', 'Case-ARSC Read Only'));
            //controller.fieldMap.put('Task',getFieldsFromLayout('Task', 'Task-RO & OAE'));
            
            //Get all Task Queues
            controller.caseQueueMap = getQueues('Case');
            controller.taskQueueMap = getQueues('Task');
            
            //Get action record being viewed/edited
            if(String.isNotBlank(actionRecId)) {
                Action__c actionRec = getActionRecord(actionRecId);
                if(actionRec != null) {
                    controller.actionRecord = actionRec;
                }
            }
        }catch(Exception e) {
            controller.hasError = true;
            controller.errorMessage = 'Exception: ' + e.getMessage();
            System.debug(controller.errorMessage);
            ApplicationLogs__c appLog = new ApplicationLogs__c(Event_Type__c = 'CREATE_ACTION_COMPONENT' , Class_Name__c = 'CreateActionController_AC', 
                                                               Error_Message__c = e.getMessage(), StackTrace__c	= e.getStackTraceString(), 
                                                               Line_Number__c = String.valueOf(e.getLineNumber()));
            insert appLog;
        }
        
        return controller;
    }
    
    @AuraEnabled
    public static CreateActionController_AC getOrgWideEmailsAndAction(String actionRecId) {
        CreateActionController_AC controller = new CreateActionController_AC();
        controller.orgWideEmails = new List<String>();
        
        //Get organization wide email addresses
        for(OrgWideEmailAddress email : [SELECT DisplayName FROM OrgWideEmailAddress ORDER BY DisplayName ASC]) {
            controller.orgWideEmails.add(email.DisplayName);
        }

        //Get action record being viewed/edited
        if(String.isNotBlank(actionRecId)) {
            Action__c actionRec = getActionRecord(actionRecId);
            if(actionRec != null) {
                controller.actionRecord = actionRec;
            }
        }        
        return controller;
    }
    
    @AuraEnabled
    public static CreateActionController_AC saveUpdateFieldAction(String newActionName, String autoTaskId, String objectToUpdate, String pageLayout, String fieldApiSelected, String newValue, String actionRecId, String editMode) {
        CreateActionController_AC controller = new CreateActionController_AC();
       
        try{
            Map<String, String> apiLabelMap = getAPIName(objectToUpdate).get('ApiKey');
            String fieldToUpdateLabel;
            Boolean fieldToUpdateChanged = false;
            Boolean duplicateRecord = false;
            
            //Get Field label from Field API
            if(String.isNotBlank(fieldApiSelected)) {
                fieldToUpdateLabel = apiLabelMap.get(fieldApiSelected);
            }
            
            String fieldUpdateRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.UPDATE_FIELD_RT).getRecordTypeId();
            Action__c newAction = new Action__c();
            newAction.Name = newActionName;
            newAction.Auto_Task__c = autoTaskId;
            newAction.Object__c = objectToUpdate;
            newAction.Layout__c = pageLayout;
            newAction.Field_To_Update__c = fieldToUpdateLabel;
            newAction.Field_To_Update_API_Name__c = fieldApiSelected;
            newAction.New_Value__c = newValue.trim();
            newAction.RecordTypeId = fieldUpdateRecordTypeId;
           
            if(editMode.equalsIgnoreCase('false')) {
                duplicateRecord = duplicateRecord(newAction);
            }else {
                newAction.Id = actionRecId;
                
                List<Action__c> oldActionRec = [SELECT Id, Field_To_Update__c FROM Action__c WHERE Id =: actionRecId];
                if(!oldActionRec.isEmpty() && oldActionRec[0].Field_To_Update__c != newAction.Field_To_Update__c) {
                    fieldToUpdateChanged = true;
                }
                
                if(fieldToUpdateChanged) {
                    duplicateRecord = duplicateRecord(newAction);
                }
            }
            //System.debug('CreateActionController_AC.saveUpdateFieldAction(): newAction = ' + newAction);
			
            //If not a duplicate record, upsert
            if(!duplicateRecord) {
                upsert newAction;
            }else {
                controller.userMessage = 'An action for ' + newAction.Object__c + ' to update ' + newAction.Field_To_Update__c + ' already exists.';
            }            
        }catch(Exception e) {
            controller.hasError = true;
            controller.errorMessage = 'Exception:'+e.getMessage();
            ApplicationLogs__c appLog = new ApplicationLogs__c(Event_Type__c = 'SAVE_FIELD_UPDATE_ACTION' , Class_Name__c = 'CreateActionController_AC', 
                                                               Error_Message__c = e.getMessage(), StackTrace__c	= e.getStackTraceString(), 
                                                               Line_Number__c = String.valueOf(e.getLineNumber()));
            insert appLog;
        }
        return controller;
    }
    
    @AuraEnabled
    public static CreateActionController_AC saveSendEmailAction(String newActionName, String autoTaskId, String templateName, String sendEmailFrom, String sendEmailTo, String recipientsEmail, String actionRecId, String editMode) {
        CreateActionController_AC controller = new CreateActionController_AC();
        String userMessage;
        
        try{
            String sendEmailRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.SEND_EMAIL_RT).getRecordTypeId();
            Action__c newAction = new Action__c();
            newAction.Name = newActionName;
            newAction.Auto_Task__c = autoTaskId;
            newAction.Template_Name__c = templateName.trim();
            newAction.Send_Email_From__c = sendEmailFrom;
            newAction.Send_Email_To__c = sendEmailTo;
            newAction.RecordTypeId = sendEmailRecordTypeId;
            if(String.isNotBlank(recipientsEmail)) {
                newAction.Recipient_s_Email_Address__c = recipientsEmail.trim();
            }
            if(editMode.equalsIgnoreCase('true')) {
                newAction.Id = actionRecId;
            }
            
            userMessage = duplicateSendEmailRecord(newAction);
            if(String.isBlank(userMessage)){
                upsert newAction;
            }else {
                controller.userMessage = userMessage;
            }
              
        }catch(Exception e) {
            controller.hasError = true;
            controller.errorMessage = 'Exception:'+e.getMessage();
            System.debug(controller.errorMessage);
            ApplicationLogs__c appLog = new ApplicationLogs__c(Event_Type__c = 'SAVE_SEND_EMAIL_ACTION' , Class_Name__c = 'CreateActionController_AC', 
                                                               Error_Message__c = e.getMessage(), StackTrace__c	= e.getStackTraceString(), 
                                                               Line_Number__c = String.valueOf(e.getLineNumber()));
            insert appLog;
        }
        return controller;
    }
    
    @AuraEnabled
    public static CreateActionController_AC saveSendSurveyAction(String newActionName, String autoTaskId, String surveyName, String sendSurveyTo, String recipientsEmail, String actionRecId, String editMode) {
        CreateActionController_AC controller = new CreateActionController_AC();
        String userMessage;
        try{
            String sendSurveyRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.SEND_SURVEY_RT).getRecordTypeId();
            Action__c newAction = new Action__c();
            newAction.Name = newActionName;
            newAction.Auto_Task__c = autoTaskId;
            newAction.Survey_Name__c = surveyName.trim();
            newAction.Send_Survey_To__c = sendSurveyTo;
            newAction.RecordTypeId = sendSurveyRecordTypeId;
            if(String.isNotBlank(recipientsEmail)) {
                newAction.Recipient_s_Email_Address__c = recipientsEmail.trim();
            }
            if(editMode.equalsIgnoreCase('true')) {
                newAction.Id = actionRecId;
            }
            
            userMessage = duplicateSendSurveyRecord(newAction);
            if(String.isBlank(userMessage)){
                upsert newAction;
            }else {
                controller.userMessage = userMessage;
            }
              
        }catch(Exception e) {
            controller.hasError = true;
            controller.errorMessage = 'Exception:'+e.getMessage();
            System.debug(controller.errorMessage);
            ApplicationLogs__c appLog = new ApplicationLogs__c(Event_Type__c = 'SAVE_SEND_SURVEY_ACTION' , Class_Name__c = 'CreateActionController_AC', 
                                                               Error_Message__c = e.getMessage(), StackTrace__c	= e.getStackTraceString(), 
                                                               Line_Number__c = String.valueOf(e.getLineNumber()));
            insert appLog;
        }
        return controller;
    }
    
    @AuraEnabled //Get action record
    public static Action__c getActionRecord(String actionRecId) {
        List<Action__c> actionList = [SELECT Id, Name, Auto_Task__c, Field_To_Update__c, Field_To_Update_API_Name__c, 
                                      Layout__c, Object__c, New_Value__c, Template_Name__c, Send_Email_To__c, Recipient_s_Email_Address__c, 
                                      Survey_Name__c, Send_Survey_To__c, Send_Email_From__c FROM Action__c WHERE Id =: actionRecId];
        if(!actionList.isEmpty()) {
            return actionList[0];
        }
        return null;
    }
    
    //Get's all the fields on the specified(input) layout
    private static Map<String, String> getFieldsFromLayout(String objectName, String layout) {
        List<String> fieldList = new List<String>();
        Map<String, String> fieldMapUnSorted = new Map<String, String>();
        Map<String, String> fieldMapSorted = new Map<String, String>();
        Set<String> requiredFieldsSet = new Set<String>();
        
        //Get fields from custom metadata to exclude
        for (Required_Fields_on_Task__mdt currentSetting : [SELECT Label, FieldSet__c FROM Required_Fields_on_Task__mdt WHERE Label = 'ROAE Fields To Exclude From CreateAction' LIMIT 1]) {
            if(!String.isBlank(currentSetting.FieldSet__c) && currentSetting.FieldSet__c.split(';') != null){
                for(String fieldName : currentSetting.FieldSet__c.split(';')){
                    requiredFieldsSet.add(fieldName);
                }
            }
        }
        Map<String, Map<String, String>> fieldMap = getAPIName(objectName);
        Map<String, String> apiLabelMap = fieldMap.get('ApiKey');
        Map<String, String> labelApiMap = fieldMap.get('LabelKey');
        List<Metadata.Metadata> layouts = 
            Metadata.Operations.retrieve(Metadata.MetadataType.Layout, 
                                         new List<String> {layout});
        
        Metadata.Layout layoutMd = (Metadata.Layout)layouts.get(0);
        for (Metadata.LayoutSection section : layoutMd.layoutSections) {
            for (Metadata.LayoutColumn column : section.layoutColumns) {
                if (column.layoutItems != null) {
                    for (Metadata.LayoutItem item : column.layoutItems) {
                        if(!requiredFieldsSet.contains(item.field)) {
                            String fieldLabel = apiLabelMap.get(item.field);
                            if(fieldLabel != null){
                                fieldList.add(fieldLabel);
                                fieldMapUnSorted.put(fieldLabel, item.field);
                            }
                        }
                    }
                }
            }
        }
        //Sort list
        fieldList.sort();
        
        //Create map with Label and API name - Sorted by Label
        for(String fieldLabel : fieldList) {
            String fieldAPI = fieldMapUnSorted.get(fieldLabel);
            if(String.isNotBlank(fieldAPI)) {
                fieldMapSorted.put(fieldLabel, fieldAPI);
            }
        }
        return fieldMapSorted;
    }
    
    //Returns a map of all fields of the specified(input) object. Key = API Name, Value = Label
    public static Map<String, Map<String, String>> getAPIName(String objectName) {
        
        Map<String, Map<String, String>> mapOfMaps = new Map<String, Map<String, String>>();
        Map<String, String> apiLabelMap = new Map<String, String>();
        Map<String, String> labelAPIMap = new Map<String, String>();
        
        Map<String, Schema.SObjectField> fieldMap = getSchema(objectName);

        //fieldName is field API name
        for (String fieldName: fieldMap.keySet()) {
            
            if(fieldMap.get(fieldName).getDescribe().isUpdateable()) {
                //To get the object fields label.
                String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
                String fieldAPI = fieldMap.get(fieldName).getDescribe().getName();
                
                apiLabelMap.put(fieldAPI, fieldLabel);
                labelAPIMap.put(fieldLabel, fieldAPI);
            }
        }
        //Add maps to map
        mapOfMaps.put('ApiKey', apiLabelMap);
        mapOfMaps.put('LabelKey', labelAPIMap);
        
        //return apiLabelMap;
        return mapOfMaps;
    }
    
    public static Map<String, Schema.SObjectField> getSchema(String objectName) {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get(objectName);
        return objectSchema.getDescribe().fields.getMap();
    }
    
     //Get all Task queues to display in a drop down
    private static Map<String, String> getQueues(String objectQueue) {
        Map<String, String> queueMap = new Map<String, String>();
        for(QueueSobject queue : [SELECT QueueId, Queue.Name FROM QueueSobject WHERE SobjectType =: objectQueue ORDER BY Queue.Name ASC]) {
            queueMap.put(queue.Queue.Name, queue.QueueId);
        }
        return queueMap;
    }
    
    //Checks if newRecord (input record) is duplicate
    private static Boolean duplicateRecord(Action__c newRecord) {
        for(Action__c existingAction : [SELECT Id, Name, Object__c, Field_To_Update_API_Name__c FROM Action__c WHERE Auto_Task__c =: newRecord.Auto_Task__c]) {
            if(existingAction.Object__c == newRecord.Object__c && existingAction.Field_To_Update_API_Name__c == newRecord.Field_To_Update_API_Name__c) {
                return true;
            }
        }
        return false;
    }
    
    //Checks if newRecord (input record) is a send email duplicate 
    private static String duplicateSendEmailRecord(Action__c newRecord) {
        String userMessage;
        String sendEmailRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.SEND_EMAIL_RT).getRecordTypeId();
        
        List<Action__c> sendEmailActionList = [SELECT Id, Template_Name__c, Send_Email_To__c FROM Action__c 
                                      WHERE Auto_Task__c =: newRecord.Auto_Task__c AND RecordTypeId =: sendEmailRecordTypeId AND Id !=: newRecord.Id];
        if(sendEmailActionList.size() >= 10) {
            userMessage = 'Only 10 emails can be sent per transaction. Update or delete a "Send Email Action" to proceed.';
            return userMessage;
        }
        
        for(Action__c existingAction : sendEmailActionList) {
            if(existingAction.Template_Name__c == newRecord.Template_Name__c && existingAction.Send_Email_To__c == newRecord.Send_Email_To__c) {
                userMessage = 'A Send Email Action for "' + existingAction.Template_Name__c + 
                    '" and Recipient "' + existingAction.Send_Email_To__c + '" already exists.';
                break;
            }
        }
        return userMessage;
    }
    
    //Checks if newRecord (input record) is a send survey duplicate 
    private static String duplicateSendSurveyRecord(Action__c newRecord) {
        String userMessage;
        String sendSurveyRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.SEND_SURVEY_RT).getRecordTypeId();
        
        for(Action__c existingAction : [SELECT Id, Survey_Name__c, Send_Survey_To__c FROM Action__c WHERE Auto_Task__c =: newRecord.Auto_Task__c 
                                        AND RecordTypeId =: sendSurveyRecordTypeId AND Id !=: newRecord.Id]) {
            if(existingAction.Survey_Name__c == newRecord.Survey_Name__c && existingAction.Send_Survey_To__c == newRecord.Send_Survey_To__c) {
                userMessage = 'A Send Survey Action for "' + existingAction.Survey_Name__c + 
                    '" and Recipient "' + existingAction.Send_Survey_To__c + '" already exists.';
                break;
            }
        }
        return userMessage;
    }
    
}