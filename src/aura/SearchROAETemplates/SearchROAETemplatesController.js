({
	init : function(component, event, helper) {
        var pageNumber = component.get("v.pageNumber");
        helper.getColumnAndAction(component, event);
		helper.getTemplates(component, event, pageNumber);
	},
    
    handleTextChange : function(component, event, helper) {
        var pageNumber = 1;
        helper.getTemplates(component, event, pageNumber);
    },
    
    handleClose : function(component, event, helper) {
        helper.closeModal(component, event);
    },
    
    handleRowAction : function(component, event, helper) {
        var action = event.getParam('action');
        switch (action.name) {
            case 'templateSelected':
                helper.templateSelected(component, event);
                break;
        }
    },
    
    handleNext : function(component, event, helper) {
        var pageNumber = component.get("v.pageNumber");  
        pageNumber++;
        helper.getTemplates(component, event, pageNumber);
    },
     
    handlePrev : function(component, event, helper) {
        var pageNumber = component.get("v.pageNumber");
        pageNumber--;
        helper.getTemplates(component, event, pageNumber);
    },
    
    handleChangePageSize : function(component, event, helper) {
        var pageNumber = 1;
        helper.getTemplates(component, event, pageNumber);
    },
})