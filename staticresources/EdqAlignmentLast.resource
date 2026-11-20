/* .slds-form-element_horizontal .slds-form-element__control, .slds-form_horizontal .slds-form-element .slds-form-element__control, .slds-form_stacked .slds-form-element_horizontal .slds-form-element__control{
padding-left: 52.5% !important;
} */

.slds-form-element .slds-form-element__label {
      font-weight: 600 !important;
      padding-top: 10px;
}

[role=combobox] input[readonly][disabled],
input[readonly][role=combobox][disabled] {
      padding: 5px 35px;
}

.attachmentalign [role=combobox] input[readonly][disabled],
.attachmentalign input[readonly][role=combobox][disabled] {
      padding: 0px 35px;
}

/* .edqComboBox .slds-combobox_container{
        padding-left: 52.5%;
}
.inputdat .slds-textarea, .inputdat .slds-combobox_container{
    margin-left: 52.5%;
} */
.dynamicdependentlabel .slds-combobox_container {
      margin-left: 52.5%;
}

.dynamicdependentlabel1 .slds-form-element .slds-input {
      margin-left: 52.5%;
}

@media(max-width:767px) {

      /* .inputdat .slds-textarea, .inputdat .slds-combobox_container{
        margin-left: 0%;
    }
    .edqComboBox .slds-combobox_container{
        padding-left: 0%;
        } */
      .slds-form-element .slds-form-element__label {
            display: block !important;
      }

      .slds-form-element .slds-checkbox__label .slds-form-element__label {
            display: inline-block !important;
            vertical-align: baseline;

      }

      .slds-form-element_horizontal .slds-form-element__control,
      .slds-form_horizontal .slds-form-element .slds-form-element__control,
      .slds-form_stacked .slds-form-element_horizontal .slds-form-element__control {
            padding-left: 0 !important;
            width: 75%;
      }

      .slds-combobox_container {
            width: 100%;
      }
}

.showRequiredform3 .slds-form-element__control {
      border: 2px solid #cc0000;
}

.showRequired .slds-form-element__control {
      border: 2px solid #cc0000;

}

/*
.descriptionShowRequired .slds-nowrap{
      border: 2px solid #cc0000;
}*/