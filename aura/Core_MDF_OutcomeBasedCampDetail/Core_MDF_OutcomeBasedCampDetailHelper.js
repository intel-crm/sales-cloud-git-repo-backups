({
    checkRecordAccess: function(component, recordId) {
var self = this;
        var action = component.get("c.checkUserRecordAccess");

        action.setParams({
            recordId: recordId,
            objectApiName: "PartnerFundRequest" 
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.hasAccess", result.hasAccess);
            } else {
                component.set("v.hasAccess", false);
            }

            component.set("v.accessChecked", true);

            if (component.get("v.hasAccess")) {
                self.loadInternalNotesObjectAccess(component);
                self.loadInternalNotes(component);
            }
        });

        $A.enqueueAction(action);
    },

    loadInternalNotesObjectAccess: function(component) {
        var action = component.get("c.getInternalNotesObjectAccess");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var access = response.getReturnValue() || {};
                component.set("v.canCreateInternalNote", !!access.canCreate);
                component.set("v.canUpdateInternalNote", !!access.canUpdate);
                component.set("v.canDeleteInternalNote", !!access.canDelete);
            }
        });
        $A.enqueueAction(action);
    },

    loadInternalNotes: function(component) {
        var recordId = component.get("v.recordId");
        if (!recordId) { return; }

        var action = component.get("c.getInternalNotes");
        action.setParams({ recordId: recordId });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var notes = response.getReturnValue() || [];
                component.set("v.internalNotesList", notes);
                component.set("v.internalNotesCount", notes.length);
                this.applyAllNotesFilterAndPagination(component);
            }
        });
        $A.enqueueAction(action);
    },

    initializeViewAllNotes: function(component) {
        component.set("v.allNotesSearchTerm", "");
        component.set("v.allNotesCurrentPage", 1);
        this.applyAllNotesFilterAndPagination(component);
    },

    applyAllNotesFilterAndPagination: function(component) {
        var notes = component.get("v.internalNotesList") || [];
        var searchTerm = (component.get("v.allNotesSearchTerm") || "").toLowerCase().trim();
        var pageSize = component.get("v.allNotesPageSize") || 10;

        var filtered = notes;
        if (searchTerm) {
            filtered = notes.filter(function(note) {
                var haystack = [
                    note.Name || "",
                    note.Title || "",
                    note.Comments || "",
                    note.CreatedByName || ""
                ].join(" ").toLowerCase();
                return haystack.indexOf(searchTerm) !== -1;
            });
        }

        component.set("v.filteredInternalNotesList", filtered);

        var totalPages = Math.max(1, Math.ceil(filtered.length / pageSize));
        var currentPage = component.get("v.allNotesCurrentPage") || 1;
        if (currentPage > totalPages) {
            currentPage = totalPages;
        }
        if (currentPage < 1) {
            currentPage = 1;
        }

        var start = (currentPage - 1) * pageSize;
        var end = start + pageSize;
        component.set("v.allNotesPagedList", filtered.slice(start, end));
        component.set("v.allNotesCurrentPage", currentPage);
        component.set("v.allNotesTotalPages", totalPages);
    },

    goToPreviousAllNotesPage: function(component) {
        var currentPage = component.get("v.allNotesCurrentPage") || 1;
        if (currentPage > 1) {
            component.set("v.allNotesCurrentPage", currentPage - 1);
            this.applyAllNotesFilterAndPagination(component);
        }
    },

    goToNextAllNotesPage: function(component) {
        var currentPage = component.get("v.allNotesCurrentPage") || 1;
        var totalPages = component.get("v.allNotesTotalPages") || 1;
        if (currentPage < totalPages) {
            component.set("v.allNotesCurrentPage", currentPage + 1);
            this.applyAllNotesFilterAndPagination(component);
        }
    },

    openNoteRecord: function(component, event) {
        var source = event.currentTarget;
        var recordId = source && source.dataset ? source.dataset.id : null;
        if (!recordId) {
            return;
        }

        var navEvent = $A.get("e.force:navigateToSObject");
        if (navEvent) {
            navEvent.setParams({
                recordId: recordId,
                slideDevName: "detail"
            });
            navEvent.fire();
            return;
        }

        window.location.href = "/" + recordId;
    },

    navigateToNotesList: function(component) {
        var recordId = component.get("v.recordId");
        if (!recordId) {
            return;
        }

        var targetUrl = "/lightning/r/PartnerFundRequest/" + recordId + "/related/Notes__r/view";
        var navEvent = $A.get("e.force:navigateToURL");
        if (navEvent) {
            navEvent.setParams({ url: targetUrl });
            navEvent.fire();
        } else {
            window.location.href = targetUrl;
        }
    },

    submitInternalNoteForm: function(component, saveAndNew) {
        var recordId = component.get("v.recordId");
        var title = component.get("v.internalNoteTitle") || "";
        var body = component.get("v.internalNoteBody") || "";
        var editId = component.get("v.internalNoteEditId");
        var isEditing = component.get("v.isEditingInternalNote");
        var self = this;

        component.set("v.internalNoteError", "");
        component.set("v.internalNoteSaveAndNew", saveAndNew);

        if (!recordId) {
            component.set("v.internalNoteError", "Missing record context. Please refresh and try again.");
            return;
        }

        var action;
        if (isEditing && editId) {
            action = component.get("c.updateInternalNote");
            action.setParams({
                noteId: editId,
                noteTitle: title,
                noteBody: body
            });
        } else {
            action = component.get("c.createInternalNote");
            action.setParams({
                parentRecordId: recordId,
                noteTitle: title,
                noteBody: body
            });
        }

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue()) {
                self.handleInternalNoteSaveSuccess(component);
                return;
            }

            var errorMessage = self.extractApexError(response.getError(), state, "Error saving Internal Note. Please try again.");

            component.set("v.internalNoteError", errorMessage);
            var toastEvent = $A.get("e.force:showToast");
            if (toastEvent) {
                toastEvent.setParams({
                    type: "error",
                    mode: "sticky",
                    title: "Save Failed",
                    message: errorMessage
                });
                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);
    },

    handleInternalNoteSaveSuccess: function(component) {
        var saveAndNew = component.get("v.internalNoteSaveAndNew");
        var isEditing = component.get("v.isEditingInternalNote");

        if (saveAndNew && !isEditing) {
            component.set("v.internalNoteTitle", "");
            component.set("v.internalNoteBody", "");
        } else {
            component.set("v.showInternalNoteForm", false);
            component.set("v.internalNoteTitle", "");
            component.set("v.internalNoteBody", "");
        }

        component.set("v.isEditingInternalNote", false);
        component.set("v.internalNoteEditId", "");

        component.set("v.internalNoteError", "");
        this.loadInternalNotes(component);

        var successToast = $A.get("e.force:showToast");
        if (successToast) {
            successToast.setParams({
                type: "success",
                mode: "dismissible",
                title: "Success",
                message: isEditing ? "Internal Note updated successfully." : (saveAndNew ? "Internal Note saved. You can add another one." : "Internal Note saved successfully.")
            });
            successToast.fire();
        }
    },

    openEditInternalNote: function(component, event) {
        var source = event.getSource();
        var noteId = source.get("v.name");
        this.openEditInternalNoteById(component, noteId);
    },

    openEditInternalNoteById: function(component, noteId) {
        if (!noteId) {
            return;
        }

        var notes = component.get("v.internalNotesList") || [];
        var selectedNote = null;
        for (var i = 0; i < notes.length; i++) {
            if (notes[i].Id === noteId) {
                selectedNote = notes[i];
                break;
            }
        }

        component.set("v.internalNoteEditId", noteId);
        component.set("v.isEditingInternalNote", true);
        component.set("v.internalNoteTitle", selectedNote ? (selectedNote.Title || "") : "");
        component.set("v.internalNoteBody", selectedNote ? (selectedNote.Comments || "") : "");
        component.set("v.internalNoteError", "");
        component.set("v.showInternalNoteForm", true);
    },

    deleteInternalNote: function(component, event) {
        var source = event.getSource();
        var noteId = source.get("v.name");
        this.deleteInternalNoteById(component, noteId);
    },

    deleteInternalNoteById: function(component, noteId) {
        if (!noteId) {
            return;
        }

        if (!confirm("Are you sure you want to delete this Internal Note?")) {
            return;
        }

        var self = this;
        var action = component.get("c.deleteInternalNote");
        action.setParams({ noteId: noteId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue()) {
                self.loadInternalNotes(component);
                var successToast = $A.get("e.force:showToast");
                if (successToast) {
                    successToast.setParams({
                        type: "success",
                        mode: "dismissible",
                        title: "Success",
                        message: "Internal Note deleted successfully."
                    });
                    successToast.fire();
                }
                return;
            }

            var errorMessage = self.extractApexError(response.getError(), state, "Error deleting Internal Note. Please try again.");
            var toastEvent = $A.get("e.force:showToast");
            if (toastEvent) {
                toastEvent.setParams({
                    type: "error",
                    mode: "sticky",
                    title: "Delete Failed",
                    message: errorMessage
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    handleInternalNoteRowAction: function(component, event) {
        var selectedValue = event.getParam("value");
        if (!selectedValue) {
            return;
        }

        var parts = selectedValue.split(":");
        var actionType = parts[0];
        var noteId = parts.length > 1 ? parts[1] : null;

        if (actionType === "EDIT") {
            this.openEditInternalNoteById(component, noteId);
            return;
        }

        if (actionType === "DELETE") {
            this.deleteInternalNoteById(component, noteId);
        }
    },

    extractApexError: function(errors, state, fallbackMessage) {
        var errorMessage = fallbackMessage;
        if (errors && errors.length > 0) {
            if (errors[0].message) {
                errorMessage = errors[0].message;
            }
            if (errors[0].pageErrors && errors[0].pageErrors.length > 0 && errors[0].pageErrors[0].message) {
                errorMessage = errors[0].pageErrors[0].message;
            }
            if (errors[0].fieldErrors) {
                var fieldNames = Object.keys(errors[0].fieldErrors);
                if (fieldNames.length > 0) {
                    var firstField = fieldNames[0];
                    var firstFieldErrors = errors[0].fieldErrors[firstField];
                    if (firstFieldErrors && firstFieldErrors.length > 0 && firstFieldErrors[0].message) {
                        errorMessage = firstFieldErrors[0].message;
                    }
                }
            }
        } else if (state && state !== "SUCCESS") {
            errorMessage = "Request failed with state: " + state;
        }

        return errorMessage;
    },

    handleInternalNoteSaveError: function(component, event) {
        var errorMessage = "Error saving Internal Note. Please try again.";
        var error = event.getParam("error");
        if (error && error.message) {
            errorMessage = error.message;
        }

        component.set("v.internalNoteError", errorMessage);

        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                type: "error",
                mode: "sticky",
                title: "Save Failed",
                message: errorMessage
            });
            toastEvent.fire();
        }
    }
})