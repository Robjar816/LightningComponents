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
        console.log("Action name = " + action.name);
        switch (action.name) {
            case 'createNote':
                helper.templateSelected(component, event, action.name);
                break;
            case 'createTask':
                helper.templateSelected(component, event, action.name);
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