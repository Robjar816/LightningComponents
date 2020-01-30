@isTest
public class DynamicDropDownController_TEST {

    static testmethod void getOptionsTest() {
        
        DynamicDropDown_Controller.getOptions();
    }
    
    static testmethod void updateCaseStatus() {
        
        Account newAccount = new Account(Name = 'Test Account');
        insert newAccount;
        
        Contact contactRecord = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = newAccount.Id);
        insert contactRecord;
        
        Test.startTest();
        DynamicDropDown_Controller.updateCaseStatus(contactRecord.Id, 'Test', 'Contact');
        Test.stopTest();
        
        Contact cRecord = [SELECT Id, Reason__c, Description FROM Contact WHERE Id =: contactRecord.Id LIMIT 1];
        System.assertEquals('Test', cRecord.Reason__c, 'Record was not updated to newValue.');
    }
}