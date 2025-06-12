<div class="form-cell" ${elementMetaData!}>
    <link rel="stylesheet" href="${request.contextPath}/plugin/org.joget.marketplace.AutocompleteTextField/css/AutocompleteTextField.css">
    <script type="text/javascript">

      var itemsPerLoad;
      var lastCount = 0;
      var query;
      var endOfResult = false;
      var blockApiResponse; // Keeps track whether to ignore or continue the processes after getting successful response
      var ongoingApiCall; // Keeps track if the API call is already in progress
      var autocompleteListContainer;
      var autocompleteField;

      // Setting the value for itemsPerLoad
      function setItemsPerLoad(){
        const userItemsPerLoad = Number("${itemsPerLoad!}"); // Gets the limit set by the user
        if(userItemsPerLoad == 0 || userItemsPerLoad == null){
          itemsPerLoad = 20; // if empty, set 20 as default
        }else{
          itemsPerLoad = userItemsPerLoad;
        }
      }
      setItemsPerLoad();

      function hideList(){
        // Hide the list and clear off the loaded items
        $(autocompleteListContainer).addClass('hide');
        $(autocompleteListContainer).find("ul").html("");
      }

      function callAPI(newQuery = true) {

        // If query is empty, skip call
        if(!query){
          hideList();
          return;
        }
        // If user typed something new instead of scrolling down to load more items
        if(newQuery){
          lastCount = 0;
          $(autocompleteListContainer).find("ul").html("");
        }else{
          lastCount = lastCount + itemsPerLoad;
        }

        // Retrieve items
        const formData = new FormData();
        formData.append("_query", query);
        formData.append("_lastCount", lastCount);
        formData.append("_itemsPerLoad", itemsPerLoad);
        $.ajax({
            url: '/jw/web/json/app/customer_supplier_partner/1/plugin/org.joget.marketplace.AutocompleteTextField/service',
            method: 'POST',
            data: formData,
            contentType: false, // Important for FormData
            processData: false, // Important for FormData
            success: function(response) {

                if(blockApiResponse){
                  return;
                }

                const autocompleteStatus = response.autocompleteStatus;
                const autocompleteResult = response.autocompleteResult;
                
                ongoingApiCall = false;

                if(autocompleteStatus == "END_OF_RESULT"){
                  endOfResult = true;
                }else{
                  endOfResult = false;
                }

                // Check if response is empty
                if(autocompleteStatus == "NO_RESULT"){
                  $(autocompleteListContainer).addClass('hide');
                }else{
                  
                  $(autocompleteListContainer).find("ul").find("#loading-indicator").remove();
                  $(autocompleteListContainer).removeClass("hide");

                  // Populate the list
                  autocompleteResult.forEach((item, index) => {
                    var li = $('<li></li>')
                      .text(item.label) // Not using decodeEntities() because .text() already decodes HTML entities
                      .attr('value', item.value)

                    if(index === autocompleteResult.length - 1){
                      $(li).addClass("no-border-bottom");
                    }

                    $(autocompleteListContainer).find("ul").append(li);
                  });

                  // Click handler for list item
                  $(autocompleteListContainer).on("click", "li", function () {
                    if($(this).attr("id") != "loading-indicator"){ // Loading indicator won't have click handler
                      $(autocompleteField).val($(this).text());
                      const selectedValue = $(this).attr("value");
                      $("#${selectionIdParamName!}").val(selectedValue);
                      hideList();
                    }
                  });

                }
            },
            error: function(xhr, status, error) {
                //
            }
        });
      }
      
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

        // Initialize selectors
        autocompleteListContainer = $(".autocomplete-list-container");
        autocompleteField = $("#${elementParamName!}");

        // Click event for text field
        $(autocompleteField).on('click', function () {
          blockApiResponse = false;
          // If the list is already rendered, no need to repopulate again
          if(!$(autocompleteListContainer).hasClass("hide")){
            return;
          }
          // Just for when user clicks outside and clicks in again
          query = $(this).val();
          callAPI();
        });
        
        // Input event for text field
        $(autocompleteField).on('input', function () {
          query = $(this).val();
          callAPI();
        });

        // Detects when scrolled to bottom for loading more items
        $(autocompleteListContainer).on('scroll', function () {

          const scrollTop = $(this).scrollTop();
          const scrollHeight = this.scrollHeight;
          const containerHeight = $(this).innerHeight();

          var listContainerClosed = (scrollTop === 0 && scrollHeight === 0 && containerHeight === 0);
          var scrolledToBottom = (scrollHeight - containerHeight == scrollTop);

          if(scrolledToBottom && !ongoingApiCall && !listContainerClosed){
            // If there is more items to load
            if(!endOfResult){
              // If loading indicator is not shown yet
              if($("#loading-indicator").length == 0){
                const li = $('<li></li>')
                    .attr("id", "loading-indicator")
                    .text("...")
                $(autocompleteListContainer).find("ul").append(li); // Show loading indicator
              }
              // Delay just to show the loading indicator
              setTimeout(function() {
                ongoingApiCall = true;
                callAPI(false);
              }, 1000);
            }
          }

        });

      });

      $(document).on('click', function (event) {
        const target = $(event.target);
        // If clicked outside the field 
        if(!$(target).closest(autocompleteListContainer).length && !$(target).closest(autocompleteField).length){
          blockApiResponse = true; // When loading more items and quickly closing the list, it will be shown again. Blocking prevents that
          hideList();
        }
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


            