/*********************************************************************
Class Name: CreateActionController_AC_Test
Created By: MST - Robert Jaramillo 
Created On: 05-13-2020
Description: Test class for CreateActionController_AC.
*********************************************************************/
@isTest
public class CreateActionController_AC_Test {

    @testSetup
    static void setup() {
        String sendEmailRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.SEND_EMAIL_RT).getRecordTypeId();
        String sendSurveyRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.SEND_SURVEY_RT).getRecordTypeId();
        
        Auto_Task__c newAutoTask = new Auto_Task__c(Name = 'AutoTask-0000');
        insert newAutoTask;
        
        List<Action__c> actionList = new List<Action__c>();
        Action__c newAction = new Action__c(Name = 'Test Action', Auto_Task__c = newAutoTask.Id, Field_To_Update__c = 'Status', Object__c = 'Case',
                                            Field_To_Update_API_Name__c = 'Status', Layout__c = 'ARSC Read Only', New_Value__c = 'Pending');
        actionList.add(newAction);
        Action__c newEmailAction = new Action__c(Name = 'Test Action', Auto_Task__c = newAutoTask.Id, Template_Name__c = 'Test Template',
                                            Send_Email_To__c = 'Other', Recipient_s_Email_Address__c = 'test@email.com', RecordTypeId = sendEmailRecordTypeId);
        actionList.add(newEmailAction);
        Action__c newSurveyAction = new Action__c(Name = 'Test Action', Auto_Task__c = newAutoTask.Id, Survey_Name__c = 'Test Survey',
                                            Send_Survey_To__c = 'Other', Recipient_s_Email_Address__c = 'test@email.com', RecordTypeId = sendSurveyRecordTypeId);
        actionList.add(newSurveyAction);
        insert actionList;
    }
    
    static testMethod void getCaseFieldsTest() {
        CreateActionController_AC controller = new CreateActionController_AC();
        List<Action__c> actionList = [SELECT Id FROM Action__c];
        Test.startTest();
        controller = CreateActionController_AC.getCaseFields(actionList[0].Id);
        Test.stopTest();
        
        System.assertEquals(false, controller.actionRecord == null, 'Action record not found.');
    }
    
    static testMethod void getOrgWideEmailsTest() {
        CreateActionController_AC controller = new CreateActionController_AC();
        List<Action__c> actionList = [SELECT Id FROM Action__c];
        Test.startTest();
        controller = CreateActionController_AC.getOrgWideEmailsAndAction(actionList[0].Id);
        Test.stopTest();
        
        System.assertEquals(false, controller.actionRecord == null, 'Action record not found.');
    }
    
    static testMethod void saveUpdateFieldActionTest() {
        CreateActionController_AC controller = new CreateActionController_AC();
        List<Auto_Task__c> autoTaskList = [SELECT Id, Name FROM Auto_Task__c];
        
        String newActionName = 'Test Action';
        String autoTaskId = autoTaskList[0].Id;
        String objectToUpdate = 'Case';
        String pageLayout = 'ARSC Read Only';
        String fieldApiSelected = 'Status';
        String newValue = 'Resolved';
        String actionRecId = null;
        String editMode = 'false';
        
        Test.startTest();
        controller = CreateActionController_AC.saveUpdateFieldAction(newActionName, autoTaskId, objectToUpdate, 
                                                                         pageLayout, fieldApiSelected, newValue, actionRecId, editMode);
        Test.stopTest();
        System.assertEquals(false, controller.userMessage == null, 'User message is empty.');
    }
    
    static testMethod void saveUpdateFieldActionEditModeTest() {
        CreateActionController_AC controller = new CreateActionController_AC();
        List<Auto_Task__c> autoTaskList = [SELECT Id, Name FROM Auto_Task__c];
        List<Action__c> actionList = [SELECT Id FROM Action__c];
        
        String newActionName = 'Test Action';
        String autoTaskId = autoTaskList[0].Id;
        String objectToUpdate = 'Case';
        String pageLayout = 'ARSC Read Only';
        String fieldApiSelected = 'Subject';
        String newValue = 'Resolved';
        String actionRecId = actionList[0].Id;
        String editMode = 'true';
        
        Test.startTest();
        controller = CreateActionController_AC.saveUpdateFieldAction(newActionName, autoTaskId, objectToUpdate, 
                                                                         pageLayout, fieldApiSelected, newValue, actionRecId, editMode);
        Test.stopTest();
        System.assertEquals(true, controller.userMessage == null, 'User message is not empty.');
    }
    
    static testMethod void saveUpdateFieldActionWithExceptionTest() {
        CreateActionController_AC controller = new CreateActionController_AC();
        
        String newActionName = 'Test Action';
        String autoTaskId = null;
        String objectToUpdate = 'Case';
        String pageLayout = 'ARSC Read Only';
        String fieldApiSelected = 'Subject';
        String newValue = 'Resolved';
        String actionRecId = null;
        String editMode = 'false';
        
        Test.startTest();
        controller = CreateActionController_AC.saveUpdateFieldAction(newActionName, autoTaskId, objectToUpdate, 
                                                                         pageLayout, fieldApiSelected, newValue, actionRecId, editMode);
        Test.stopTest();
        System.assertEquals(true, controller.hasError, 'Exception was not caught.');
    }
    
    static testMethod void saveSendEmailActionTest() {
        CreateActionController_AC controller = new CreateActionController_AC();
        String sendEmailRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.SEND_EMAIL_RT).getRecordTypeId();
        List<Auto_Task__c> autoTaskList = [SELECT Id, Name FROM Auto_Task__c];
        
        String newActionName = 'Test Send Email Action';
        String autoTaskId = autoTaskList[0].Id;
        String templateName = 'Test Template';
        String sendEmailFrom = 'ARSC';
        String sendEmailTo = 'Other';
        String recipientsEmail = 'test@email.com';
        String actionRecId = null;
        String editMode = 'false';
        
        Test.startTest();
        controller = CreateActionController_AC.saveSendEmailAction(newActionName, autoTaskId, templateName, sendEmailFrom,
                                                                         sendEmailTo, recipientsEmail, actionRecId, editMode);
        Test.stopTest();
        System.assertEquals(false, controller.userMessage == null, 'User message is empty.');
    }
    
    static testMethod void saveSendEmailActionEditModeTest() {
        CreateActionController_AC controller = new CreateActionController_AC();
        String sendEmailRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.SEND_EMAIL_RT).getRecordTypeId();
        
        List<Auto_Task__c> autoTaskList = [SELECT Id, Name FROM Auto_Task__c];
        List<Action__c> actionList = [SELECT Id FROM Action__c WHERE RecordTypeId =: sendEmailRecordTypeId];
        
        String newActionName = 'Test Send Email Action';
        String autoTaskId = autoTaskList[0].Id;
        String templateName = 'Test Template';
        String sendEmailFrom = 'ARSC';
        String sendEmailTo = 'Other';
        String recipientsEmail = 'test@email.com';
        String actionRecId = actionList[0].Id;
        String editMode = 'true';
        
        Test.startTest();
        controller = CreateActionController_AC.saveSendEmailAction(newActionName, autoTaskId, templateName, sendEmailFrom, 
                                                                         sendEmailTo, recipientsEmail, actionRecId, editMode);
        Test.stopTest();
        System.assertEquals(true, controller.userMessage == null, 'User message is not empty.');
    }
    
    static testMethod void saveSendEmailActionWithExceptionTest() {
        CreateActionController_AC controller = new CreateActionController_AC();        
       
        String newActionName = 'Test Send Email Action';
        String autoTaskId = null;
        String templateName = 'Test Template';
        String sendEmailFrom = 'ARSC';
        String sendEmailTo = 'Other';
        String recipientsEmail = 'test@email.com';
        String actionRecId = null;
        String editMode = 'false';
        
        Test.startTest();
        controller = CreateActionController_AC.saveSendEmailAction(newActionName, autoTaskId, templateName, sendEmailFrom,
                                                                         sendEmailTo, recipientsEmail, actionRecId, editMode);
        Test.stopTest();
        System.assertEquals(true, controller.hasError, 'Exception was not caughtt.');
    }
    
    static testMethod void saveSendSurveyActionTest() {
        CreateActionController_AC controller = new CreateActionController_AC();
        String sendSurveyRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.SEND_SURVEY_RT).getRecordTypeId();
        List<Auto_Task__c> autoTaskList = [SELECT Id, Name FROM Auto_Task__c];
        
        String newActionName = 'Test Send Email Action';
        String autoTaskId = autoTaskList[0].Id;
        String surveyName = 'Test Survey';
        String sendSurveyTo = 'Other';
        String recipientsEmail = 'test@email.com';
        String actionRecId = null;
        String editMode = 'false';
        
        Test.startTest();
        controller = CreateActionController_AC.saveSendSurveyAction(newActionName, autoTaskId, surveyName, sendSurveyTo, 
                                                                    recipientsEmail, actionRecId, editMode);
        Test.stopTest();
        System.assertEquals(false, controller.userMessage == null, 'User message is empty.');
    }
    
    static testMethod void saveSendSurveyActionEditModeTest() {
        CreateActionController_AC controller = new CreateActionController_AC();
        String sendSurveyRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.SEND_SURVEY_RT).getRecordTypeId();
        
        List<Auto_Task__c> autoTaskList = [SELECT Id, Name FROM Auto_Task__c];
        List<Action__c> actionList = [SELECT Id FROM Action__c WHERE RecordTypeId =: sendSurveyRecordTypeId];
        
        String newActionName = 'Test Send Email Action';
        String autoTaskId = autoTaskList[0].Id;
        String surveyName = 'Test Survey';
        String sendSurveyTo = 'Other';
        String recipientsEmail = 'test@email.com';
        String actionRecId = actionList[0].Id;
        String editMode = 'true';
        
        Test.startTest();
        controller = CreateActionController_AC.saveSendSurveyAction(newActionName, autoTaskId, surveyName, sendSurveyTo, 
                                                                    recipientsEmail, actionRecId, editMode);
        Test.stopTest();
        System.assertEquals(true, controller.userMessage == null, 'User message is not empty.');
    }
    
    static testMethod void saveSendSurveyActionWithExceptionTest() {
        CreateActionController_AC controller = new CreateActionController_AC();
        
        String newActionName = 'Test Send Email Action';
        String autoTaskId = null;
        String surveyName = 'Test Survey';
        String sendSurveyTo = 'Other';
        String recipientsEmail = 'test@email.com';
        String actionRecId = null;
        String editMode = 'false';
        
        Test.startTest();
        controller = CreateActionController_AC.saveSendSurveyAction(newActionName, autoTaskId, surveyName, sendSurveyTo, 
                                                                    recipientsEmail, actionRecId, editMode);
        Test.stopTest();
        System.assertEquals(true, controller.hasError, 'Exception was not caught.');
    }
}