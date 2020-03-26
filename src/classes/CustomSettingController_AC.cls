/*
Class Name: CustomSettingController_AC
Created By: Sahil Handa
Created On: 02-19-2020
Description: Apex Controller for the CustomSettingConfiguration lightning component.
*/

public class CustomSettingController_AC {
    //This method is to Create a new template (Custom Setting) 
    @AuraEnabled
    public static void saveTemplate (String templateBody,String templateName){
        try{
            System.debug('templateBody'+templateBody);
            System.debug('templateName'+templateName);
            RO_OAE_Template__c temp = new RO_OAE_Template__c();
            temp.Name = templateName;
            temp.Body__c = templateBody;
            insert temp;
            
        } catch (Exception ex){
            system.debug('Exception'+ex.getMessage());
        }
    }  
    //This method is to get the custom settings for the data table to display in UI
    @AuraEnabled
    public static List<RO_OAE_Template__c> getCustomSettingsRecord (String templateName){
        try{
            List<RO_OAE_Template__c> templateList = [SELECT id,Name,Body__c FROM RO_OAE_Template__c];
            List<RO_OAE_Template__c> templateListUpdated = new List<RO_OAE_Template__c>();
            for(RO_OAE_Template__c temp :templateList ){
                temp.Body__c = temp.Body__c ;//.replaceAll('<[^>]+>',' ');
                templateListUpdated.add(temp); 
            }
            return templateListUpdated;
        } catch (Exception ex){
            system.debug('Exception'+ex.getMessage());
            return null;
        }
    } 
    // This method is to delete the custom setting record
    @AuraEnabled
    public static void deleteTemplate (RO_OAE_Template__c recId){
        try{
            delete recId;
        } catch (Exception ex){
            system.debug('Exception'+ex.getMessage());
            
        }
    }   
    //This method is to update the existing custom setting record
    @AuraEnabled
    public static void updateTemplate (RO_OAE_Template__c recId){
        try{
            System.debug('recId updates'+recId);
            update recId;
        } catch (Exception ex){
            system.debug('Exception'+ex.getMessage());
            
        }
    }
}