package org.joget.marketplace;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.json.JSONArray;
import org.json.JSONObject;
import org.joget.apps.app.service.AppUtil;
import org.joget.apps.form.model.Element;
import org.joget.apps.form.model.FormBuilderPaletteElement;
import org.joget.apps.form.model.FormData;
import org.joget.apps.form.model.FormRow;
import org.joget.apps.form.model.FormRowSet;
import org.joget.apps.form.service.FormUtil;
import org.joget.plugin.base.PluginWebSupport;
public class AutocompleteTextField extends Element implements FormBuilderPaletteElement, PluginWebSupport {

    protected static Collection<Map> optionMap = null;

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
        // Gets the value set by user for Items Per Load
        if (getPropertyString("itemsPerLoad") != null) {
            String itemsPerLoad = getPropertyString("itemsPerLoad");
            dataModel.put("itemsPerLoad", itemsPerLoad);
        }
        
        // set options
        optionMap = getOptionMap(formData);
        dataModel.put("options", optionMap);

        String html = FormUtil.generateElementHtml(this, formData, template, dataModel);
        return html;
    }
    
    @Override
    public void webService(HttpServletRequest request, HttpServletResponse response) throws IOException  {
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            
            String autocompleteStatus = "";
            List<Map<String, String>> autocompleteResult = getAutocompleteResult(request.getParameter("_query"));

            if (autocompleteResult.isEmpty()) {
                autocompleteStatus = "NO_RESULT"; // Don't show the list container
            } else {
                int lastCount = Integer.valueOf(request.getParameter("_lastCount")); // Keeps track of how many items have already been loaded in the list
                int itemsPerLoad = Integer.valueOf(request.getParameter("_itemsPerLoad")); // How many items to show after first load and when scrolling down each time
                // If count for loaded items is still smaller than the entire entries list
                if (lastCount < autocompleteResult.size()) {
                    // Discard all previously loaded items
                    autocompleteResult = autocompleteResult.subList(lastCount, autocompleteResult.size());
                    // If the limit is still smaller than the entire entries count
                    if (itemsPerLoad < autocompleteResult.size()) {
                        // Only send out first X (Items Per Load) of entries
                        autocompleteResult = autocompleteResult.subList(0, itemsPerLoad);
                    } else {
                        autocompleteResult = autocompleteResult.subList(0, autocompleteResult.size()); // Give what's left
                    }
                } else {
                    autocompleteResult = new ArrayList<>();
                    autocompleteStatus = "END_OF_RESULT"; // No more items left
                }
            }

            JSONObject jsonObject = new JSONObject();
            jsonObject.put("autocompleteResult", new JSONArray(autocompleteResult));
            jsonObject.put("autocompleteStatus", autocompleteStatus);

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            try (PrintWriter out = response.getWriter()) {
                out.print(jsonObject.toString());
                out.flush();
            }
        }
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

    /**
     * Returns a list of entries where the "label" contains the given query string.
     * @param query The search string used to filter entries.
     * @return A list of maps where each map's "label" contains the query string.
     */
    public static List<Map<String, String>> getAutocompleteResult(String query) {
        if (query == null || query.isEmpty()) {
            return new ArrayList<>();
        }
        List<Map<String, String>> results = new ArrayList<Map<String, String>>();
        for (Map map : optionMap) {
            if (map.get("label") != null) {
                String label = map.get("label").toString().toLowerCase();
                if (label.contains(query.toLowerCase())) {
                    results.add(map);
                }
            }
        }
        return results;
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
