public class DynamicDropDown_Controller {
        
    @AuraEnabled
    public Boolean hasError; //Used to verify any exception occurred
    
    @AuraEnabled
    public String errorMessage; //Used to hold the exception message
    
    @AuraEnabled
    public String userMessage; //Used to hold the custom error message
    
    @AuraEnabled
    public Map<String, String> dependentMap; //Used to store dependent field values. 
    
    @AuraEnabled
    public List<String> options; //Used to store controlling field values.
        
    @AuraEnabled
    public DynamicDropDown_Controller controller;
    
    @AuraEnabled
    public static DynamicDropDown_Controller getOptions() {
        
        List<String> optionList = new List<String>();
        
        DynamicDropDown_Controller controller = new DynamicDropDown_Controller();
        controller.options = new List<String>();
        controller.dependentMap = new Map<String, String>();

        for(Reason_Option__mdt metadataOption : [SELECT MasterLabel, Dependent_Reason__c FROM Reason_Option__mdt ORDER BY MasterLabel ASC LIMIT 300]) {
            controller.options.add(metadataOption.MasterLabel);
            controller.dependentMap.put(metadataOption.MasterLabel, metadataOption.Dependent_Reason__c);
        }
        System.debug('controller.options = ' + controller.options);
        return controller;
    }
    
    @AuraEnabled
    public static DynamicDropDown_Controller updateCaseStatus(String recordId, String newValue, String depNewValue) {
        
        DynamicDropDown_Controller controller = new DynamicDropDown_Controller();
        controller.hasError = false;
        controller.userMessage = '';
        controller.errorMessage = '';
        
        List<Contact> contactList = [SELECT Id, Reason__c, Description FROM Contact WHERE Id =: recordId];
        Contact contactRecord = (!contactList.isEmpty()) ? contactList[0] : null;
        if(contactRecord != null) {
            try{
                contactRecord.Reason__c = newValue;
                contactRecord.Description = depNewValue;
            	update contactRecord;
            }catch(Exception e) {
                controller.hasError = true;
                controller.errorMessage = 'Exception: ' + e.getMessage();
            }
        }
        return controller;
    }
    
    
}