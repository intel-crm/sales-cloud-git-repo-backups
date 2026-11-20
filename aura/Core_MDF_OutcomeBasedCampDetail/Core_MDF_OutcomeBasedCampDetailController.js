({
    doInit: function(component, event, helper) {
        var recordId = component.get("v.recordId");

        if (!recordId) {
            var params = new URLSearchParams(window.location.search);

            if (params.has('c__recordId')) {
                recordId = params.get('c__recordId');
            } else if (params.has('recordId')) {
                recordId = params.get('recordId');
            }
        }

        component.set("v.recordId", recordId);

        var isCommunity = window.location.pathname.includes('/s/');
        component.set("v.isInternalPage", !isCommunity);

        if (recordId) {
            helper.checkRecordAccess(component, recordId);
        } else {
            component.set("v.hasAccess", false);
            component.set("v.errorMessage", $A.get("$Label.c.Core_MDF_NoRecordsFound"));
            component.set("v.accessChecked", true);
        }
    },

    handleNewInternalNote: function(component, event, helper) {
        component.set("v.internalNoteTitle", "");
        component.set("v.internalNoteBody", "");
        component.set("v.internalNoteError", "");
        component.set("v.showInternalNoteForm", true);
    },

    handleCancelNote: function(component, event, helper) {
        component.set("v.showInternalNoteForm", false);
        component.set("v.internalNoteTitle", "");
        component.set("v.internalNoteBody", "");
        component.set("v.internalNoteError", "");
        component.set("v.isSavingInternalNote", false);
        component.set("v.isEditingInternalNote", false);
        component.set("v.internalNoteEditId", "");
    },

    handleSaveNote: function(component, event, helper) {
        var trimmedValue = (component.get("v.internalNoteTitle") || "").trim();
        component.set("v.internalNoteTitle", trimmedValue);
        component.set("v.internalNoteError", "");

        if (!trimmedValue) {
            component.set("v.internalNoteError", "Title is required.");
            component.set("v.isSavingInternalNote", false);
            return;
        }
        component.set("v.isSavingInternalNote", true);
        helper.submitInternalNoteForm(component, false);
    },

    handleSaveAndNewNote: function(component, event, helper) {
        var trimmedValue = (component.get("v.internalNoteTitle") || "").trim();
        component.set("v.internalNoteTitle", trimmedValue);
        component.set("v.internalNoteError", "");

        if (!trimmedValue) {
            component.set("v.internalNoteError", "Title is required.");
            component.set("v.isSavingInternalNote", false);
            return;
        }
        component.set("v.isSavingInternalNote", true);
        helper.submitInternalNoteForm(component, true);
    },

    handleInternalNoteSaveSuccess: function(component, event, helper) {
        helper.handleInternalNoteSaveSuccess(component);
    },

    handleInternalNoteSaveError: function(component, event, helper) {
        helper.handleInternalNoteSaveError(component, event);
    },

    handleViewAllNotes: function(component, event, helper) {
        helper.navigateToNotesList(component);
    },

    handleCloseViewAllNotes: function(component, event, helper) {
        component.set("v.showAllInternalNotes", false);
    },

    handleAllNotesSearchChange: function(component, event, helper) {
        component.set("v.allNotesCurrentPage", 1);
        helper.applyAllNotesFilterAndPagination(component);
    },

    handleAllNotesPrevPage: function(component, event, helper) {
        helper.goToPreviousAllNotesPage(component);
    },

    handleAllNotesNextPage: function(component, event, helper) {
        helper.goToNextAllNotesPage(component);
    },

    handleOpenNoteRecord: function(component, event, helper) {
        helper.openNoteRecord(component, event);
    },

    handleEditInternalNote: function(component, event, helper) {
        helper.openEditInternalNote(component, event);
    },

    handleDeleteInternalNote: function(component, event, helper) {
        helper.deleteInternalNote(component, event);
    },

    handleInternalNoteRowAction: function(component, event, helper) {
        helper.handleInternalNoteRowAction(component, event);
    }
})