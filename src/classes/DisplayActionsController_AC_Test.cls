/*********************************************************************
Class Name: DisplayActionsController_AC_Test
Created By: MST - Robert Jaramillo 
Created On: 05-13-2020
Description: Test class for DisplayActionsController_AC.
*********************************************************************/
@isTest
public class DisplayActionsController_AC_Test {
    
    @testSetup
    static void setup() {
        String fieldUpdateRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.UPDATE_FIELD_RT).getRecordTypeId();
        String sendEmailRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.SEND_EMAIL_RT).getRecordTypeId();
        String sendSurveyRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.SEND_SURVEY_RT).getRecordTypeId();
        
        Auto_Task__c newAutoTask = new Auto_Task__c(Name = 'AutoTask-0000');
        insert newAutoTask;
        
        List<Action__c> actionList = new List<Action__c>();
        Action__c newAction = new Action__c(Name = 'Test Action', Auto_Task__c = newAutoTask.Id, Field_To_Update__c = 'Status', Object__c = 'Case',
                                            Field_To_Update_API_Name__c = 'Status', Layout__c = 'ARSC Read Only', New_Value__c = 'Pending',
                                           RecordTypeId = fieldUpdateRecordTypeId);
        actionList.add(newAction);
        Action__c newEmailAction = new Action__c(Name = 'Test Action', Auto_Task__c = newAutoTask.Id, Template_Name__c = 'Test Template',
                                            Send_Email_To__c = 'Other', Recipient_s_Email_Address__c = 'test@email.com', RecordTypeId = sendEmailRecordTypeId);
        actionList.add(newEmailAction);
        Action__c newSurveyAction = new Action__c(Name = 'Test Action', Auto_Task__c = newAutoTask.Id, Survey_Name__c = 'Test Survey',
                                            Send_Survey_To__c = 'Other', Recipient_s_Email_Address__c = 'test@email.com', RecordTypeId = sendSurveyRecordTypeId);
        actionList.add(newSurveyAction);
        insert actionList;
    }

    static testMethod void getActionsFieldUpdateTest() {
        List<Action__c> actionList = new List<Action__c>();
        List<Auto_Task__c> autoTaskList = [SELECT Id FROM Auto_Task__c];
        
        Test.startTest();
        actionList = DisplayActionsController_AC.getActions(autoTaskList[0].Id, RecordTypeConstants_AC.UPDATE_FIELD_RT);
        Test.stopTest();
        
        System.assertEquals(false, actionList.isEmpty(), 'List returned is empty.');
    }
    
    static testMethod void getActionsSendEmailTest() {
        List<Action__c> actionList = new List<Action__c>();
        List<Auto_Task__c> autoTaskList = [SELECT Id FROM Auto_Task__c];
        
        Test.startTest();
        actionList = DisplayActionsController_AC.getActions(autoTaskList[0].Id, RecordTypeConstants_AC.SEND_EMAIL_RT);
        Test.stopTest();
        
        System.assertEquals(false, actionList.isEmpty(), 'List returned is empty.');
    }
    
    static testMethod void getActionsSendSurveyTest() {
        List<Action__c> actionList = new List<Action__c>();
        List<Auto_Task__c> autoTaskList = [SELECT Id FROM Auto_Task__c];
        
        Test.startTest();
        actionList = DisplayActionsController_AC.getActions(autoTaskList[0].Id, RecordTypeConstants_AC.SEND_SURVEY_RT);
        Test.stopTest();
        
        System.assertEquals(false, actionList.isEmpty(), 'List returned is empty.');
    }
    
    static testMethod void deleteActionTest() {
        DisplayActionsController_AC controller = new DisplayActionsController_AC();
        List<Action__c> actionList = [SELECT Id FROM Action__c];
        
        Test.startTest();
        controller = DisplayActionsController_AC.deleteAction(actionList[0].Id);
        Test.stopTest();
        
        System.assertEquals(null, controller.hasError, 'An exception was caught.');
    }
}