public class ValidateFieldsController {

    @AuraEnabled
    public Boolean hasError; //Used to verify any exception occurred
    
    @AuraEnabled
    public String errorMessage; //Used to hold the exception message
    
    @AuraEnabled
    public String userMessage; //Used to hold the custom error message
    
    @AuraEnabled
    public Account accRec;
    
    @AuraEnabled
    public ValidateFieldsController controller;
    
    //Used to collect Growth Opportunity Info to check the retired and Approved records
    @AuraEnabled
    public static ValidateFieldsController accInfo(Id accId) {
        
        ValidateFieldsController controller = new ValidateFieldsController();
        
        controller.accRec =  [SELECT Id, OwnerId, Active__c, Rating FROM Account WHERE Id =: accId];
        return controller;
        
    }
    
    //Used to verify the required fields are filled before submitting the reocrd for approval.
    //Approval process will be triggered automatically once all the required filed are filled
    @AuraEnabled
    public static ValidateFieldsController checkRequiredFields(Id accId) {
        
        ValidateFieldsController controller = new ValidateFieldsController();
        controller.hasError = false;
        controller.userMessage = '';
        DescribeSObjectResult describe = SObjectType.Account;
        Map<String, SObjectField> allFields = describe.fields.getMap(); 
        Set<String> requiredFieldsSet = new Set<String>();
        Map<String, Account_Mandatory_Fields__mdt> accRequiredFieldMap = new Map<String, Account_Mandatory_Fields__mdt>();
        
        //Dynamic query building 
        String accQuery = 'SELECT Id, Name, Active__c, Rating';
        
        //To get all the list of required fields from the custom meta data
        for (Account_Mandatory_Fields__mdt currentSetting : [SELECT Label, FieldSet__c FROM Account_Mandatory_Fields__mdt LIMIT 1]) {
            if(!String.isBlank(currentSetting.FieldSet__c) && currentSetting.FieldSet__c.split(';') != null){
                for(String fieldName : currentSetting.FieldSet__c.split(';')){
                    requiredFieldsSet.add(fieldName);
                    accQuery += ', '+fieldName;
                }
            }
        }
        
        accQuery += ' FROM Account WHERE Id =: accId';
        Account accInfo = Database.query(accQuery);
        System.debug('accQuery = ' + accQuery);
        System.debug('accInfo = ' + accInfo);
        
        //To add the field label to the custom error message if the required fields are not filled
        for(String fieldName : requiredFieldsSet) {
            if(String.isBlank(String.valueOf(accInfo.get(fieldName)))) {
                DescribeFieldResult nameDescribe = allFields.get(fieldName).getDescribe();
                if(String.isBlank(controller.userMessage)) {
                    controller.userMessage += nameDescribe.getLabel();
                } else {
                    controller.userMessage += +', '+nameDescribe.getLabel();
                }
            }
        }
        System.debug('controller.userMessage = ' + controller.userMessage);
        //To submit the records for approval if all the required fields are filled.
        if(!String.isBlank(controller.userMessage)) {
            controller.userMessage += ' field value is mandatory for submitting for approval.';
        } else {
            try {
                Approval.ProcessSubmitRequest accApprovalRequest =    new Approval.ProcessSubmitRequest();
                accApprovalRequest.setComments('Account submitted for approval');
                accApprovalRequest.setObjectId(accId);
                Approval.ProcessResult result = Approval.process(accApprovalRequest);
            } catch(Exception e){
                controller.hasError = true;
                controller.errorMessage = 'Exception:'+e.getMessage();
            }
        }
        
        return controller;
        
    }
}