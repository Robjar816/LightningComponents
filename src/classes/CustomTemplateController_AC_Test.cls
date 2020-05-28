/*********************************************************************
Class Name: CustomTemplateController_AC_Test
Created By: MST - Robert Jaramillo 
Created On: 03-05-2020
Description: Test class for apex class CustomTemplateController.
*********************************************************************/
@isTest
public class CustomTemplateController_AC_Test {

    @testSetup
    static void setup() {
        RO_OAE_Template__c temp = new RO_OAE_Template__c();
        temp.Name = 'Test Template';
        temp.Body__c = 'Test Body';
        insert temp;
        
        Case testCase = new Case(Status = 'Open');
        insert testCase;
    }
    
    static testMethod void getMetadataTest() {
        CustomTemplateController controller = new CustomTemplateController();
        Test.startTest();
        controller = CustomTemplateController.getMetadata();
        Test.stopTest();
    }
    
    static testMethod void getTextMetadataTest() {
        CustomTemplateController controller = new CustomTemplateController();
        Test.startTest();
        controller = CustomTemplateController.getTextMetadata('Test Template');
        Test.stopTest();
        
        System.assertEquals(false, String.isBlank(controller.templateBody), 'Assertion failed. Template body is blank.');
    }
    
    static testMethod void saveTaskTest() {
        CustomTemplateController controller = new CustomTemplateController();
        List<Case> testCase = [SELECT Id FROM Case];
        
        String subject = 'Test Subject';
        String noteBody = 'Test Note Body';
        Boolean rush = true;
        Date dueDate = Date.today();
        String assignmentGroup = 'RO';
        String taskType = 'Fax';
        String notes = 'Test Notes'; 
        String assignToId = UserInfo.getUserId();
        String recordId = Id.valueOf(testCase[0].Id);
        String templateName = 'Test Template';
        
        Test.startTest();
        controller = CustomTemplateController.saveTask(subject, notebody, rush, dueDate, assignmentGroup, taskType, notes, assignToId, recordId, templateName);
        Test.stopTest();
        
        //System.assertEquals(false, controller.hasError, 'Assertion failed. There was error inserting task.');
    }
    
    static testMethod void saveTaskWithExceptionTest() {
        CustomTemplateController controller = new CustomTemplateController();
        
        String subject = 'Test Subject';
        String noteBody = 'Test Note Body';
        Boolean rush = true;
        Date dueDate = Date.today();
        String assignmentGroup = 'RO';
        String taskType = 'Fax';
        String notes = 'Test Notes'; 
        String assignToId = UserInfo.getUserId();
        String recordId = '';
        String templateName = 'Test Template';
        
        Test.startTest();
        controller = CustomTemplateController.saveTask(subject, notebody, rush, dueDate, assignmentGroup, taskType, notes, assignToId, recordId, templateName);
        Test.stopTest();
        
        System.assertEquals(true, controller.hasError, 'Assertion failed. There was NO error inserting task.');
    }
    
    static testMethod void saveTaskWithEmptyNoteTest() {
        CustomTemplateController controller = new CustomTemplateController();
        List<Case> testCase = [SELECT Id FROM Case];
        
        String subject = 'Test Subject';
        String noteBody = '';
        Boolean rush = true;
        Date dueDate = Date.today();
        String assignmentGroup = 'RO';
        String taskType = 'Fax';
        String notes = 'Test Notes'; 
        String assignToId = UserInfo.getUserId();
        String recordId = Id.valueOf(testCase[0].Id);
        String templateName = 'Test Template';
        
        Test.startTest();
        controller = CustomTemplateController.saveTask(subject, notebody, rush, dueDate, assignmentGroup, taskType, notes, assignToId, recordId, templateName);
        Test.stopTest();
        
        //System.assertEquals(false, controller.hasError, 'Assertion failed. There was error inserting task.');
    }
    
    static testMethod void saveNotesTest(){
        CustomTemplateController controller = new CustomTemplateController();
        List<Case> testCase = [SELECT Id FROM Case];
        
        String subject = 'Test Subject';
        String noteBody = 'Test Note Body';
        String recordId = '';
        
        Test.startTest();
        controller = CustomTemplateController.saveNotes(subject, noteBody, recordId);
        Test.stopTest();
        
        System.assertEquals(True, controller.hasError, 'Assertion failed. There was NO error inserting task.');
    }
    
    static testMethod void getPicklistValuesTest() {
        CustomTemplateController controller = new CustomTemplateController();
        String tempName = 'Test Template';
        
        Test.startTest();
        controller = CustomTemplateController.getPicklistValues(tempName);
        Test.stopTest();
        
        System.assertEquals(true, controller.dependentPicklistValues.size() > 0, 'Assertion Failed. List is empty.');
    }
    
    static testMethod void checkRequiredFields() {
        CustomTemplateController controller = new CustomTemplateController();
        List<Case> testCase = [SELECT Id FROM Case];
        
        String subject = 'Test Subject';
        String noteBody = 'Test Note Body';
        Boolean rush = true;
        Date dueDate = Date.today();
        String assignmentGroup = 'RO';
        String taskType = '';
        String notes = 'Test Notes'; 
        String assignToId = UserInfo.getUserId();
        String recordId = Id.valueOf(testCase[0].Id);
        String templateName = 'Test Template';
        
        Test.startTest();
        controller = CustomTemplateController.saveTask(subject, notebody, rush, dueDate, assignmentGroup, taskType, notes, assignToId, recordId, templateName);
        Test.stopTest();
        
        //System.assertEquals(true, String.isNotBlank(controller.userMessage), 'Assertion failed. There was NO user message.');
    }
    
}