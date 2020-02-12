public class AutoPopulateRichText_Controller {

    @AuraEnabled
    public Boolean hasError; //Used to verify any exception occurred
    
    @AuraEnabled
    public String errorMessage; //Used to hold the exception message
    
    @AuraEnabled
    public String userMessage; //Used to hold the custom error message
    
    @AuraEnabled
    public List<String> templateList;
    
    @AuraEnabled
    public Map<String, String> templateMap;
    
    @AuraEnabled
    public AutoPopulateRichText_Controller controller;
    
    @AuraEnabled
    public static AutoPopulateRichText_Controller getTemplates() {
        
        AutoPopulateRichText_Controller controller = new AutoPopulateRichText_Controller();
        controller.templateList = new List<String>{'-- None --'};
            controller.templateMap = new Map<String, String>{'-- None --' => ''};
        controller.hasError = false;
        controller.userMessage = '';
        controller.errorMessage = '';
        
        for(Template__mdt template : [SELECT MasterLabel, Template_Content__c FROM Template__mdt ORDER BY MasterLabel ASC LIMIT 300]) {
            controller.templateList.add(template.MasterLabel);
            controller.templateMap.put(template.MasterLabel, template.Template_Content__c);
        }
        System.debug('controller.templateList =  ' + controller.templateList);
        System.debug('controller.templateMap =  ' + controller.templateMap);
        return controller;
    }
    
    @AuraEnabled
    public static AutoPopulateRichText_Controller saveNote(String recordId, String noteContent) {
        
        AutoPopulateRichText_Controller controller = new AutoPopulateRichText_Controller();
        controller.hasError = false;
        controller.userMessage = '';
        controller.errorMessage = '';
        
        if(noteContent == '' || noteContent == null) {
            controller.userMessage = 'Enter text to template';
        } else {
            try {
                ContentVersion  cnt = new ContentVersion();
                cnt.VersionData = Blob.valueOf(noteContent);
                cnt.Title = 'Test Note';
                cnt.PathOnClient = cnt.Title + '.snote';
                cnt.FirstPublishLocationId = recordId;
                insert cnt;
            } catch(Exception e) {
                controller.hasError = true;
                controller.errorMessage = 'Exception: ' + e.getMessage();
            }
        }        
        return controller;
    }
}