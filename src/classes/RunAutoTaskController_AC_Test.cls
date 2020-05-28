/*********************************************************************
Class Name: RunAutoTaskController_AC_Test
Created By: MST - Robert Jaramillo 
Created On: 05-14-2020
Description: Test class for RunAutoTaskController_AC.
*********************************************************************/
@isTest
public class RunAutoTaskController_AC_Test {

    @testSetup
    static void setup() {
        String recordType = System.Label.Task_RO_OAE_RT;
        String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        String updateFieldRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.UPDATE_FIELD_RT).getRecordTypeId();
        String sendEmailRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.SEND_EMAIL_RT).getRecordTypeId();
        String sendSurveyRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.SEND_SURVEY_RT).getRecordTypeId();
        String personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('02 - Engaged Student').getRecordTypeId();
        String ARSCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ARSC').getRecordTypeId();
        
        Account testAcc = new Account(FirstName = 'Test', LastName = 'Account', RecordTypeId = personAccountRecordTypeId);
        insert testAcc;
        
        Case testCase = new Case(Status = 'Open', Subject = 'Test Case', ROAE_Type__c = 'ACADEMIC RECORD',
                                            ROAE_Subtype__c = 'Academic Status: Advisement', RecordTypeId = ARSCRecordTypeId);
        insert testCase;
        
        Task testTask = new Task(Subject = 'Test Subject', ROAE_Assignment_Group__c = 'RO', ROAE_Task_Type__c = 'APA', 
                                 Status = 'Resolved', WhatId = testCase.Id, RecordTypeId = taskRecordTypeId);
        insert testTask;
                
        Auto_Task__c newAutoTask = new Auto_Task__c(Name = 'AutoTask-0000');
        insert newAutoTask;
        
        List<Action__c> actionList = new List<Action__c>();
        Action__c caseAction = new Action__c(Name = 'Test Action', Auto_Task__c = newAutoTask.Id, Field_To_Update__c = 'Status', Object__c = 'Case',
                                            Field_To_Update_API_Name__c = 'Status', Layout__c = 'ARSC Read Only', New_Value__c = 'Pending', 
                                            RecordTypeId = updateFieldRecordTypeId);
        actionList.add(caseAction);
        
        Action__c caseAction2 = new Action__c(Name = 'Test Action 2', Auto_Task__c = newAutoTask.Id, Field_To_Update__c = 'Rush', Object__c = 'Case',
                                            Field_To_Update_API_Name__c = 'Rush__c', Layout__c = 'ARSC Read Only', New_Value__c = 'false', 
                                            RecordTypeId = updateFieldRecordTypeId);
        actionList.add(caseAction2);
        
        Action__c newTaskAction = new Action__c(Name = 'Task - Update Status', Auto_Task__c = newAutoTask.Id, Field_To_Update__c = 'Status', Object__c = 'Task',
                                            Field_To_Update_API_Name__c = 'Status', Layout__c = 'RO & OAE', New_Value__c = 'Pending', 
                                                RecordTypeId = updateFieldRecordTypeId);
        actionList.add(newTaskAction);
        
        Action__c newTaskAction2 = new Action__c(Name = 'Task - Update Rush', Auto_Task__c = newAutoTask.Id, Field_To_Update__c = 'Rush', Object__c = 'Task',
                                            Field_To_Update_API_Name__c = 'ROAE_Rush__c', Layout__c = 'RO & OAE', New_Value__c = 'false', 
                                                RecordTypeId = updateFieldRecordTypeId);
        actionList.add(newTaskAction2);
        
        Action__c newEmailAction = new Action__c(Name = 'Send Email', Auto_Task__c = newAutoTask.Id, Template_Name__c = 'Denied Task', Send_Email_From__c = 'Do Not Reply',
                                            Send_Email_To__c = 'Other', Recipient_s_Email_Address__c = 'test@email.com', RecordTypeId = sendEmailRecordTypeId);
        actionList.add(newEmailAction);
        
        Action__c newEmailAction2 = new Action__c(Name = 'Send Email 2', Auto_Task__c = newAutoTask.Id, Template_Name__c = 'ARSC Rush Case', Send_Email_From__c = 'Do Not Reply',
                                            Send_Email_To__c = 'Case Creator', RecordTypeId = sendEmailRecordTypeId);
        actionList.add(newEmailAction2);
        
        Action__c newEmailAction3 = new Action__c(Name = 'Send Email 3', Auto_Task__c = newAutoTask.Id, Template_Name__c = 'Internal Case Review', Send_Email_From__c = 'Do Not Reply',
                                            Send_Email_To__c = 'Case Owner', RecordTypeId = sendEmailRecordTypeId);
        actionList.add(newEmailAction3);
        
        Action__c newSurveyAction = new Action__c(Name = 'Send Survey', Auto_Task__c = newAutoTask.Id, Survey_Name__c = 'Test Survey',
                                            Send_Survey_To__c = 'Other', Recipient_s_Email_Address__c = 'test@email.com', RecordTypeId = sendSurveyRecordTypeId);
        actionList.add(newSurveyAction);
        
        Action__c newSurveyAction2 = new Action__c(Name = 'Send Survey 2', Auto_Task__c = newAutoTask.Id, Survey_Name__c = 'Test Survey2',
                                            Send_Survey_To__c = 'Case Creator', Recipient_s_Email_Address__c = 'test@email.com', RecordTypeId = sendSurveyRecordTypeId);
        actionList.add(newSurveyAction2);
        insert actionList;
        
    }
    
    static testMethod void getAutoTasksTest() {
        RunAutoTaskController_AC controller = new RunAutoTaskController_AC();
        List<Case> caseList = [SELECT Id FROM Case];
        String caseId = caseList[0].Id;
        Test.startTest();
        controller = RunAutoTaskController_AC.getAutoTasks(caseId);
        Test.stopTest();
        
        System.assertEquals(false, controller.autoTaskMap == null, 'Auto Task record not found.');
    }
    
    static testMethod void getTaskAndRunAutoTaskTest() {
        
        RunAutoTaskController_AC controller = new RunAutoTaskController_AC();
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User newUser = new User(Alias = 'utest', Email='test@email.com',
                                Emailencodingkey='UTF-8', FirstName='First', Lastname='Last', languagelocalekey='en_US',
                                Localesidkey='en_US', ProfileId = profile.Id, timezonesidkey='Europe/London', username='testSurveyProcess@myemail.com');
        insert newUser;
        
        List<PermissionSet> levelIIPM = [SELECT Id FROM PermissionSet WHERE Label = 'ROAE Update Resolved Case - Level II'];
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = levelIIPM[0].Id, AssigneeId = newUser.Id);
        insert psa;
        
        Test.startTest();
        System.runAs(newUser) {            
            List<Case> caseList = [SELECT Id FROM Case];
            List<Task> taskList = [SELECT Id, Subject FROM Task];
            List<Auto_Task__c> autoTaskList = [SELECT Id FROM Auto_Task__c];
            caseList[0].Status = 'Resolved';
            caseList[0].Last_Case_Comment__c = 'Test';
            update caseList;      
            
            controller = RunAutoTaskController_AC.getTaskAndRunAutoTask(caseList[0].Id, autoTaskList[0].Id,taskList[0].Id);
        }
        Test.stopTest();
        
        System.assertEquals(null, controller.hasError, 'Error encountered: ' + controller.errorMessage);
    }
    
    static testMethod void doesSurveyExistTest() {
        String userMessage;
        
        String sendSurveyRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.SEND_SURVEY_RT).getRecordTypeId();
        List<Action__c> actList = [SELECT Id, Survey_Name__c FROM Action__c WHERE RecordTypeId =: sendSurveyRecordTypeId];
        
        Test.startTest();
        userMessage = RunAutoTaskController_AC.doesSurveyExist(actList[0]);
        Test.stopTest();
        
        System.assertEquals(false, String.isEmpty(userMessage), 'User message was empty. Survey found.');
    }
    
    static testMethod void catchExceptionTest() {
        RunAutoTaskController_AC controller = new RunAutoTaskController_AC();
        String ARSCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ARSC').getRecordTypeId();
        String updateFieldRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.UPDATE_FIELD_RT).getRecordTypeId();
        
        List<Case> testCase = [SELECT ID FROM Case];
        
        Auto_Task__c newAutoTask = new Auto_Task__c(Name = 'AutoTask-0000');
        insert newAutoTask;
        
        Action__c caseAction = new Action__c(Name = 'Test Action', Auto_Task__c = newAutoTask.Id, Field_To_Update__c = 'Status', Object__c = 'Case',
                                            Field_To_Update_API_Name__c = 'Invalid_Field__z', Layout__c = 'ARSC Read Only', New_Value__c = 'Pending', 
                                            RecordTypeId = updateFieldRecordTypeId);
        insert caseAction;
        
        Test.startTest();
    	controller = RunAutoTaskController_AC.runAutoTasks(testCase[0].Id, newAutoTask.Id, null, false);
        Test.stopTest();
        
        System.assertEquals(true, controller.hasError, 'An error was NOT encountered.');
    }
    
    static testMethod void queryAndUpdateRecordTest() {
        String updateFieldRecordTypeId = Schema.SObjectType.Action__c.getRecordTypeInfosByName().get(RecordTypeConstants_AC.UPDATE_FIELD_RT).getRecordTypeId();
        
        List<Case> testCase = [SELECT ID FROM Case];
        List<Action__c> actList = [SELECT Id, Field_To_Update_API_Name__c, New_Value__c FROM Action__c WHERE RecordTypeId =: updateFieldRecordTypeId AND Name = 'Test Action'];
        
        Test.startTest();
        RunAutoTaskController_AC.queryAndUpdateRecord(actList, testCase[0], 'Case', false);
        Test.stopTest();
    }
}