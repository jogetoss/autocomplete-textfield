package org.joget.marketplace;

import java.util.Collection;
import java.util.Map;
import org.joget.apps.app.service.AppUtil;
import org.joget.apps.form.model.Element;
import org.joget.apps.form.model.FormBuilderPaletteElement;
import org.joget.apps.form.model.FormData;
import org.joget.apps.form.model.FormRow;
import org.joget.apps.form.model.FormRowSet;
import org.joget.apps.form.service.FormUtil;

public class AutocompleteTextField extends Element implements FormBuilderPaletteElement {

    @Override
    public String getName() {
        return "Autocomplete Text Field";
    }

    @Override
    public String getVersion() {
        return "7.0.0";
    }

    @Override
    public String getDescription() {
        return "Autocomplete Text Field with AJAX loaded options based on matching keywords";
    }
    
    /**
     * Returns the option key=value pairs for this select box.
     * @param formData
     * @return
     */
    public Collection<Map> getOptionMap(FormData formData) {
        Collection<Map> optionMap = FormUtil.getElementPropertyOptionsMap(this, formData);
        return optionMap;
    }
    
    public static String replaceLast(String text, String regex, String replacement) {
        return text.replaceFirst("(?s)"+regex+"(?!.*?"+regex+")", replacement);
    }
    
    @Override
    public String renderTemplate(FormData formData, Map dataModel) {
        String template = "AutocompleteTextField.ftl";

        // set textfield with value (option label)
        String value = FormUtil.getElementPropertyValue(this, formData);
        dataModel.put("value", value);
        
        // set hidden field with id (option value)
        if(getPropertyString("selection_id") != null){
            String selectionIDElementName = getPropertyString("selection_id");
            String currentElementName = FormUtil.getElementParameterName(this);
            selectionIDElementName = replaceLast(currentElementName, getPropertyString(FormUtil.PROPERTY_ID), selectionIDElementName);
            dataModel.put("selectionIdParamName", selectionIDElementName);
        }
        
        // set options
        Collection<Map> optionMap = getOptionMap(formData);
        dataModel.put("options", optionMap);

        String html = FormUtil.generateElementHtml(this, formData, template, dataModel);
        return html;
    }
    
    @Override
    public FormRowSet formatData(FormData formData) {
        FormRowSet rowSet = null;

        // get value
        String id = getPropertyString(FormUtil.PROPERTY_ID);
        if (id != null) {
            String value = FormUtil.getElementPropertyValue(this, formData);
            if (value != null) {
                // set value into Properties and FormRowSet object
                FormRow result = new FormRow();
                result.setProperty(id, value);
                
                rowSet = new FormRowSet();
                rowSet.add(result);
            }
        }
        return rowSet;
    }

    @Override
    public String getClassName() {
        return getClass().getName();
    }

    @Override
    public String getFormBuilderTemplate() {
        return "<label class='label'>Autocomplete Text Field</label><input type='text' />";
    }

    @Override
    public String getLabel() {
        return "Autocomplete Text Field";
    }

    @Override
    public String getPropertyOptions() {
        return AppUtil.readPluginResource(getClass().getName(), "/properties/form/AutocompleteTextField.json", null, true, "messages/form/AutocompleteTextField");
    }

    @Override
    public String getFormBuilderCategory() {
        return "Marketplace";
    }

    @Override
    public int getFormBuilderPosition() {
        return 100;
    }

    @Override
    public String getFormBuilderIcon() {
        return "/plugin/org.joget.apps.form.lib.TextField/images/textField_icon.gif";
    }    
}
