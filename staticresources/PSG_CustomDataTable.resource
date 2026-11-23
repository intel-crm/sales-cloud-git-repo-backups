.picklist-container,
.lookup-container{
    width : 90%;
    margin: 0 auto;
}

.picklist-container .slds-dropdown,
.lookup-container .slds-dropdown{
    position: relative !important;
    z-index: 99 !important;
    max-height: 120px;
    overflow: scroll;
}

[lightning-combobox_combobox-host]{
    <!-- margin-bottom: 17px; -->
	margin-bottom: 5px;
    margin-top: -10px;
}

th.slds-has-focus, td.slds-has-focus{
    box-shadow: none !important;
}


.slds-table_edit thead th:first-child{
    width: 60px;
}



.slds-is-edited {
   font-weight: normal !important;
    background-color: var(--slds-g-color-neutral-base-100, rgb(255, 255, 255)) !important;
}
.slds-table .slds-cell-edit.slds-is-edited, .slds-table .slds-cell-edit.slds-is-edited:hover {
    font-weight: normal !important;
    background-color: var(--slds-g-color-neutral-base-100, rgb(255, 255, 255)) !important;
}
td.slds-cell-edit.slds-text-color_default.slds-is-edited.slds-theme_error:hover {
    background-color: var(--slds-g-color-neutral-base-100, rgb(255, 255, 255)) !important;;
}

td.slds-cell-edit.slds-theme_default.slds-text-color_default.slds-is-edited {
	
    background-color: var(--slds-g-color-neutral-base-100, rgb(255, 255, 255)) !important;
    font-weight: normal !important;
}
td.slds-theme_error.slds-text-color_default.slds-cell-edit:hover {
    background-color: var(--slds-g-color-neutral-base-100, rgb(255, 255, 255)) !important;
}
.slds-table_edit.slds-table tbody td:hover>.slds-cell-edit:hover, .slds-table--edit.slds-table tbody td:hover>.slds-cell-edit:hover {
    background-color: var(--slds-g-color-neutral-base-100, var(--lwc-colorBackgroundAlt,rgb(255, 255, 255)));
}

td.slds-theme_error.slds-text-color_default.slds-cell-edit:hover {
    background-color: var(--slds-g-color-neutral-base-100, var(--lwc-colorBackgroundAlt,rgb(255, 255, 255)));
}

td.slds-cell-edit.slds-text-color_default.slds-is-edited.slds-theme_error {
    background-color: var(--slds-g-color-error-base-50, var(--lwc-colorBackgroundToastError, rgb(234, 0, 30))) !important;
}
.slds-hint-parent .slds-cell-edit .slds-button__icon_edit, .slds-hint-parent .slds-cell-edit .slds-button__icon--edit, .slds-hint-parent .slds-cell-edit .slds-button__icon_lock, .slds-hint-parent .slds-cell-edit .slds-button__icon--lock,.slds-hint-parent .slds-cell-edit .slds-button__icon_lock, .slds-hint-parent .slds-cell-edit .slds-button__icon--lock:hover {
     opacity: 10; 
}