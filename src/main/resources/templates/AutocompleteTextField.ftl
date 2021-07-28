<div class="form-cell" ${elementMetaData!}>
    <link rel="stylesheet" href="${request.contextPath}/plugin/org.joget.marketplace.AutocompleteTextField/css/AutocompleteTextField.css"></script>
    <script type="text/javascript">
      $(function(){
        var decodeEntities = (function() {
            // this prevents any overhead from creating the object each time
            var element = document.createElement('div');

            function decodeHTMLEntities (str) {
              if(str && typeof str === 'string') {
                // strip script/html tags
                str = str.replace(/<script[^>]*>([\S\s]*?)<\/script>/gmi, '');
                str = str.replace(/<\/?\w(?:[^"'>]|"[^"]*"|'[^']*')*>/gmi, '');
                element.innerHTML = str;
                str = element.textContent;
                element.textContent = '';
              }

              return str;
            }

            return decodeHTMLEntities;
          })();

        var selections = [
            <#list options as option>
                {
                    value: "${option.value!?html}",
                    label: "${option.label!?html}"
                },
            </#list>
            {
                value: "",
                label: ""
            }
        ];
        selections.pop();
        $("#${elementParamName!}").autocomplete({
          source: selections,
          select: function( event, ui ) {
              $("#${elementParamName!}").val( decodeEntities(ui.item.label) );
              <#if selectionIdParamName! != ''>
              $("#${selectionIdParamName!}").val( ui.item.value );
              </#if>
              return false;
            }
        }).autocomplete( "instance" )._renderItem = function( ul, item ) {
            return $( "<li>" )
              .append( "<div>" + item.label + "</div>" )
              .appendTo( ul );
        };
      });
    </script>
    <label class="label">${element.properties.label} <span class="form-cell-validator">${decoration}</span><#if error??> <span class="form-error-message">${error}</span></#if></label>
    <#if (element.properties.readonly! == 'true' && element.properties.readonlyLabel! == 'true') >
        <div class="form-cell-value"><span>${value!?html}</span></div>
        <input id="${elementParamName!}" name="${elementParamName!}" type="hidden" value="${value!?html}" />
    <#else>
        <input id="${elementParamName!}" name="${elementParamName!}" type="text" size="${element.properties.size!}" value="${value!?html}" maxlength="${element.properties.maxlength!}" <#if error??>class="form-error-cell"</#if> <#if element.properties.readonly! == 'true'>readonly</#if> />
    </#if>
</div>


            