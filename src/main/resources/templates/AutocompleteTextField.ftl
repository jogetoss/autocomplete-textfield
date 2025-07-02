<div class="form-cell" ${elementMetaData!}>
    <link rel="stylesheet" href="${request.contextPath}/plugin/org.joget.marketplace.AutocompleteTextField/css/AutocompleteTextField.css">
    <script src="${request.contextPath}/plugin/org.joget.marketplace.AutocompleteTextField/js/AutocompleteTextField.js"></script>
    <script type="text/javascript">
      $(function() {
        $('#${elementParamName!}').autocompleteTextField({
          elementParamName : "${elementParamName!}",
          itemsPerLoad: Number('${itemsPerLoad!}'),
          selectionIdSelector: '#${selectionIdParamName!}'
        });
      });
    </script>
    <label class="label">${element.properties.label} <span class="form-cell-validator">${decoration}</span><#if error??> <span class="form-error-message">${error}</span></#if></label>
    <#if (element.properties.readonly! == 'true' && element.properties.readonlyLabel! == 'true') >
        <div class="form-cell-value"><span>${value!?html}</span></div>
        <input id="${elementParamName!}" name="${elementParamName!}" type="hidden" value="${value!?html}" />
    <#else>
        <div class="autocomplete-field-container">
          <input id="${elementParamName!}" name="${elementParamName!}" type="text" size="${element.properties.size!}" value="${value!?html}" maxlength="${element.properties.maxlength!}" <#if error??>class="form-error-cell"</#if> <#if element.properties.readonly! == 'true'>readonly</#if> />
          <div class="autocomplete-list-container hide">
            <ul></ul>
          </div>         
        </div>
    </#if>
</div>


            