/*********************************************************************
Class Name: sendEmailComponentController_Test
Created By: MST - Matt Billups 
Created On: 05-08-2020
Description: Controller for the sendEmail custom lightning component.
*********************************************************************/

public class sendEmailComponentController {
    @AuraEnabled 
    public static String sendMailMethod(String sendTo, String sendToContactId, String sendToUserId, String mSubject, String mbody, String caseId, String folderId, String templateId, 
                                        String ccEmail, List<String> attachments, String fromAddress){
        
        string caseNumber = '';
        String caseOwnerName = '' ;
        String returnMessage;
        
        User recipientUser;
        Contact recipientContact;
        if(sendToUserId != null && sendToUserId != '') recipientUser = [SELECT Id, email FROM User WHERE Id =: sendToUserId];
        if(sendToContactId != null && sendToContactId != '') recipientContact = [SELECT Id, Email, Name, isPersonAccount FROM Contact WHERE Id =: sendToContactId];
        //if(recipientContact.isPersonAccount) System.debug('Contact Email: ' + recipientContact.PersonEmail); 
        //System.debug('Contact: ' + recipientContact.Name);   
        
        // Split up the cc addresses into a list
        List<String> ccAddresses = new List<String>();
        System.debug('ccEmail: ' + ccEmail);
        if(ccEmail != null && ccEmail != '') ccAddresses = ccEmail.split(';');   
        
        // get the template
        list<EmailTemplate> tempList = new list<EmailTemplate>();
        tempList = [SELECT Id,Subject,Body,HtmlValue From EmailTemplate where id =: templateId limit 1];
        
        // get the case record
        if(caseId != null ){ 
            Case c = [select Id, CaseNumber, Owner.Name from Case where Id =: caseId];
            caseNumber = c.CaseNumber;
            if(c.Owner.Name != null){
                caseOwnerName = String.ValueOf(c.Owner.Name);
            }
        }
        
        // Get the files to attach to the email
        System.debug('Attachments List: ' + attachments);
        List<ContentVersion> docs = [SELECT Id, ContentDocumentId, Title, VersionData, FileType FROM ContentVersion WHERE ContentDocumentId IN: attachments];
        //List<ContentDocument> docsToDelete = [SELECT Id FROM ContentDocument WHERE Id IN: attachments];        
        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
        for(ContentVersion c : docs) {
            Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
            att.body = c.VersionData;
            //att.ContentType = c.FileType;
            att.FileName = c.Title + '.' + c.FileType;
            emailAttachments.add(att);
        }
                                             
        List<EmailMessage> emailmessageList =  new List<EmailMessage>();
        emailmessageList = [select id, Subject,TextBody from emailmessage where EmailTemplateId =: templateId order By createddate desc limit 1];        
        
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendToList = new List<String>();
        if(recipientUser != null) sendToList.add(recipientUser.Email);
        if(recipientContact != null) sendToList.add(recipientContact.Email);
        mail.setToAddresses(sendToList);
        if(fromAddress == userInfo.getUserEmail()) mail.setSenderDisplayName(userInfo.getName()); 
        mail.setSubject(mSubject);
        mail.setCcAddresses(ccAddresses);
        if(recipientUser != null) mail.saveAsActivity = false;
        mail.setHtmlBody(mbody);
        if(recipientContact != null) mail.setTargetObjectId(recipientContact.Id);         
        mail.setWhatId(caseId);
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setTreatBodiesAsTemplate(true);
        if(!tempList.isEmpty()) mail.setTemplateId(tempList.get(0).id);
        mail.setFileAttachments(emailAttachments);
                                            
		if(fromAddress != userInfo.getUserEmail()){
            String emailAddId = [SELECT id, Address FROM OrgWideEmailAddress WHERE Address =: fromAddress].Id;
            mail.setOrgWideEmailAddressId(emailAddId);
        }                                             
                                            
        mails.add(mail);

        // Create an email message record to store in Salesforce if the recipient is a User
        EmailMessage newMessage = new EmailMessage();        
        if(sendTo == 'User') {
            newMessage.ParentId = caseId;
            newMessage.MessageDate = System.now();
            newMessage.htmlBody = mBody;
            newMessage.TextBody = mBody;
            newMessage.Subject = mSubject;
            newMessage.FromName = userInfo.getName();
            //newMessage.Status = 'Sent';
            newMessage.FromAddress = userInfo.getUserEmail();
            if(recipientUser != null) newMessage.ToAddress = recipientUser.Email;
                   
        }         
        
        try{
            if(sendTo == 'User') insert newMessage;
            Messaging.sendEmail(mails);
            //delete docsToDelete;            
            return '1';
        
        } catch (Exception e) {
        
            System.debug('Error: ' + e.getMessage());            
            return e.getMessage();
        
        }
        
    }   
    
    /*@AuraEnabled
    public static list<emailTemplateWrapper> getEmailTemplates(){
        list<emailTemplateWrapper> emailTemplateWrapperlist = new list<emailTemplateWrapper>();
        
        map<String,emailTemplateWrapper> folderIdVsTemplateMap = new map<String,emailTemplateWrapper>();
        //Folder folderObj = new Folder();
        //folderObj= [SELECT Id, Name, Type FROM Folder where Name='RO & OAE' AND Type ='Email'];

        // Code for adding all folders not just "RO & OAE" - runs into CPU limit
        List<Folder> folderList = new List<Folder>();
        folderList= [SELECT Id,Name, Type FROM Folder WHERE (Name='RO & OAE' OR Name='ARSC CS') AND Type = 'Email'];  
        //System.debug('folderList: ' + folderList.size());
        // Add Folder Ids to a list
        List<Id> folderIds = new List<Id>();
        for(Folder f : folderList){ 
            System.debug('folder: ' + f.Name);       
            folderIds.add(f.Id);        
        }     
        for(sobject emailtemp : [ SELECT Id, FolderId, HtmlValue, FolderName, isActive, body,Name,subject FROM EmailTemplate where isActive= true and FolderId IN: folderIds]){  
        //for(sobject emailtemp : [ SELECT Id, FolderId, HtmlValue, FolderName, isActive, body,Name,subject FROM EmailTemplate where isActive= true and FolderId =: folderObj.Id]){ 
            System.debug('Inside for loop.');
            if( folderIdVsTemplateMap.containskey( String.valueof(emailtemp.get('FolderId'))) ){
                
                EmailTemplates template = new EmailTemplates();
                template.emailTemplateId = String.valueOf(emailtemp.get('Id'));
                template.emailTemplatename = String.valueOf(emailtemp.get('Name'));
                System.debug('Email body: ' + emailtemp.get('body'));
                template.emailbody = (emailtemp.get('HtmlValue') != null ? String.valueOf(emailtemp.get('HtmlValue')).unescapeHtml4() : String.valueOf(emailtemp.get('body')).unescapeHtml4() );
                template.emailSubject = String.valueOf(emailtemp.get('subject'));
                folderIdVsTemplateMap.get( String.valueof(emailtemp.get('FolderId')) ).emailtemplatelist.add( template );
                
            }else{
                emailTemplateWrapper tempWrap = new emailTemplateWrapper();
                tempWrap.folderId = String.valueOf(emailtemp.get('FolderId'));
                tempWrap.folderName = String.valueOf(emailtemp.get('FolderName'));
                
                emailTemplates template = new emailTemplates();
                template.emailTemplateId = String.valueOf(emailtemp.get('Id'));
                template.emailTemplatename = String.valueOf(emailtemp.get('Name'));
                template.emailbody = (emailtemp.get('HtmlValue') != null ? String.valueOf(emailtemp.get('HtmlValue')).unescapeHtml4() : String.valueOf(emailtemp.get('body')).unescapeHtml4() );
                template.emailSubject = String.valueOf(emailtemp.get('subject'));
                tempWrap.emailtemplatelist = new list<emailTemplates>{ template };
                folderIdVsTemplateMap.put( String.valueof(emailtemp.get('FolderId'))  , tempWrap );
            }   
        }
        
        if( !folderIdVsTemplateMap.isEmpty() ){
            emailTemplateWrapperlist.addAll( folderIdVsTemplateMap.values() );
            
            return emailTemplateWrapperlist;
        }
        return null;
    }*/
    
    public class emailTemplateWrapper{
        
        @AuraEnabled 
        public String folderName{get;set;}
        
        @AuraEnabled 
        public String folderId{get;set;}
        
        @AuraEnabled
        public list<emailTemplates> emailtemplatelist{get;set;}
        
    }
    
    public class emailTemplates{
        
        @AuraEnabled 
        public String emailTemplateId{get;set;}
        
        @AuraEnabled 
        public String emailbody{get;set;}
        
        @AuraEnabled
        public String emailSubject {get;set;}
        
        @AuraEnabled 
        public String emailTemplatename{get;set;}
    }  
    
    @AuraEnabled
    public static Case getCaseRec(String caseId){
        Case caseObj = new Case();
        caseObj = [select Id, CaseNumber from Case where Id=: caseId Limit 1];
        return caseObj;
        
    }
    
    @AuraEnabled
    public static List<emailTemplateWrapper> getTemplateFolders(){
        List<emailTemplateWrapper> folderNames = new List<emailTemplateWrapper>();
        List<Folder> folders = [select Id, Name, DeveloperName, Type FROM Folder WHERE Type = 'Email'];
        for(Folder f : folders){
            emailTemplateWrapper wrap = new emailTemplateWrapper();
            wrap.folderName = f.Name;
            wrap.folderId = f.Id;
            folderNames.add(wrap);
        }
        
        return folderNames;
        
    }
    
    @AuraEnabled
    public static List<emailTemplates> getTemplates(String folderId){
        List<emailTemplates> templateNames = new List<emailTemplates>();
        List<EmailTemplate> templates = [select Id, Name, DeveloperName, FolderId, Subject, Body, HtmlValue FROM EmailTemplate WHERE FolderId =: folderId];
        for(EmailTemplate e : templates){
            emailTemplates temp = new emailTemplates();
            temp.emailTemplatename = e.Name;
            temp.emailTemplateId = e.Id;
            temp.emailSubject = e.Subject;
            temp.emailbody = (e.HtmlValue != null ? String.valueOf(e.HtmlValue).unescapeHtml4() : String.valueOf(e.body).unescapeHtml4());
            templateNames.add(temp);
        }
        
        return templateNames;
        
    }
    
    @AuraEnabled
    public static List<String> getFromAddresses(){
        List<String> fromAddresses = new List<String>();
        fromAddresses.add(userInfo.getUserEmail());
		for(OrgWideEmailAddress owa : [select id, Address from OrgWideEmailAddress]) {
        	fromAddresses.add(owa.Address);   
        }
        System.debug('From Address List: ' + fromAddresses);
        return fromAddresses;
        
    }
}