@isTest
public class ValidateFieldsController_TEST {

    static testmethod void accInfo() {
        
        Account newAccount =  new Account();
        newAccount.Name = 'Test Account';
        newAccount.Active__c = 'No';
        
        Test.startTest();
        insert newAccount;
        Test.stopTest();
        
        ValidateFieldsController.accInfo(newAccount.Id);
        System.assertEquals(newAccount.Active__c, 'No');
    }
    
    static testmethod void accMissingFields() {
        
        Account newAccount =  new Account();
        newAccount.Name = 'Test Account';
        newAccount.Active__c = 'No';
        
        Test.startTest();
        insert newAccount;
        Test.stopTest();
        
        ValidateFieldsController.checkRequiredFields(newAccount.Id);
        System.assertEquals(newAccount.Active__c, 'No');
    }

    static testmethod void accNotMissingFieldValues() {
        
        Account newAccount =  new Account();
        newAccount.Name = 'Test Account';
        newAccount.Active__c = 'Yes';
        newAccount.Type = 'Prospect';
        newAccount.AccountNumber = '1235';
        newAccount.Site = 'site';
        
        Test.startTest();
        insert newAccount;
        Test.stopTest();
        
        ValidateFieldsController.checkRequiredFields(newAccount.Id);
        System.assertEquals(newAccount.Active__c, 'No');
        
    }
    
    static testmethod void notSubmittedForApproval() {
        
        Account newAccount =  new Account();
        newAccount.Name = 'Test Account';
        newAccount.Active__c = 'No';
        newAccount.Type = 'Prospect';
        newAccount.AccountNumber = '1235';
        newAccount.Site = 'site';
        
        Test.startTest();
        insert newAccount;
        Test.stopTest();
        
        ValidateFieldsController.checkRequiredFields(newAccount.Id);
        System.assertEquals(newAccount.Active__c, 'No');
        
    }
}