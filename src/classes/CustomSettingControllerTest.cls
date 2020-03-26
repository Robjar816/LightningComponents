/*
Class Name: CustomSettingControllerTest
Created By: Sahil Handa
Created On: 02-19-2020
Description: Test class for apex class CustomSettingController_AC.
*/

@isTest 
public class CustomSettingControllerTest {
    
    //
    private static testMethod void createTemplate() {
        String templateBody =' This is the body';
        String templateName = 'Test Custom Setting';
        CustomSettingController_AC.saveTemplate(templateBody, templateName);
        
        List<RO_OAE_Template__c> customSettingList =   CustomSettingController_AC.getCustomSettingsRecord ( templateName);
        CustomSettingController_AC.updateTemplate (customSettingList[0]);
        
        CustomSettingController_AC.deleteTemplate (customSettingList[0]);
        RO_OAE_Template__c temp = new RO_OAE_Template__c(Name = '',Body__c ='');
        CustomSettingController_AC.updateTemplate (temp);
        
        CustomSettingController_AC.deleteTemplate (temp);
        List<RO_OAE_Template__c> customSettingList2 =   CustomSettingController_AC.getCustomSettingsRecord ( templateName);
        
    }
}