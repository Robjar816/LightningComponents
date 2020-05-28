/*********************************************************************
Class Name: SearchROAETemplates_AC
Created By: Mission Possible - Robert Jaramillo 
Created On: 04-13-2020
Description: Controller for DisplayActions lightning component.
*********************************************************************/
public class DisplayActionsController_AC {
    
    @AuraEnabled
    public Boolean hasError; //Used to verify any exception occurred
    
    @AuraEnabled
    public String errorMessage; //Used to hold the exception message
    
    @AuraEnabled
    public String userMessage; //Used to hold the custom error message
    
    @AuraEnabled
    public DisplayActionsController_AC controller;
    
    @AuraEnabled
    public static List<Action__c> getActions(String recordId, String recordType) {
        String actionRecordTypeId;
        String orderByField;
        
        if(recordType.equals(RecordTypeConstants_AC.UPDATE_FIELD_RT)) {
            actionRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.UPDATE_FIELD_RT).getRecordTypeId();
            orderByField = 'Object__c';
        }else if(recordType.equals(RecordTypeConstants_AC.SEND_EMAIL_RT)) {
            actionRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.SEND_EMAIL_RT).getRecordTypeId();
            orderByField = 'Name';
        }else {
            actionRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.SEND_SURVEY_RT).getRecordTypeId();
            orderByField = 'Name';
        }

		String query = 'SELECT Id, Name, Object__c, Record_Type_Name__c, Field_To_Update__c, New_Value__c, Layout__c, Template_Name__c, ' +
                'Send_Email_To__c, Send_Email_From__c, Survey_Name__c, Send_Survey_To__c, Recipient_s_Email_Address__c ' + 
            'FROM Action__c WHERE Auto_Task__c =: recordId AND RecordTypeId =: actionRecordTypeId ORDER BY ' + orderByField + ' ASC';
        return Database.query(query);
    }
    
    @AuraEnabled
    public static DisplayActionsController_AC deleteAction(String recordId) {
        DisplayActionsController_AC controller = new DisplayActionsController_AC();
        
        try{
            List<Action__c> actionToDelete = [SELECT Id FROM Action__c WHERE Id =: recordId];
            if(!actionToDelete.isEmpty()) {
                delete actionToDelete;
            }
        }catch(Exception e) {
            controller.hasError = true;
            controller.errorMessage = 'Exception:' + e.getMessage();
            ApplicationLogs__c appLog = new ApplicationLogs__c(Event_Type__c = 'DELETE_ACTION' , Class_Name__c = 'DisplayActionsController_AC', 
                                                               Error_Message__c = e.getMessage(), StackTrace__c	= e.getStackTraceString(), 
                                                               Line_Number__c = String.valueOf(e.getLineNumber()));
            insert appLog;
        }
        return controller;
    }
    
}