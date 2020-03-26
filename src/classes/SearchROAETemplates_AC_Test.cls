/*********************************************************************
Class Name: SearchROAETemplates_AC_Test
Created By: MST - Robert Jaramillo 
Created On: 03-16-2020
Description: Test class for apex class SearchROAETemplates_AC.
*********************************************************************/
@isTest
public class SearchROAETemplates_AC_Test {
    
    @testSetup
    static void setup() {
        RO_OAE_Template__c testTemplate = new RO_OAE_Template__c(Name = 'Test Template', Body__c ='Template Body');
        insert testTemplate;
    }
    static testMethod void getAllTemplatesTestWithoutInput() {
        
        Test.startTest();
        List<RO_OAE_Template__c> testTemplate = SearchROAETemplates_AC.getAllTemplates('');
        Test.stopTest();
        System.assertEquals(true, testTemplate.size() > 0, 'Template list is empty.');
    }
    
    static testMethod void getAllTemplatesTestWithInput() {
        
        Test.startTest();
        List<RO_OAE_Template__c> testTemplate = SearchROAETemplates_AC.getAllTemplates('Test');
        Test.stopTest();
        System.assertEquals(true, testTemplate.size() > 0, 'Template list is empty.');
    }

}