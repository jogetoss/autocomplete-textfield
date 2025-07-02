(function($) {
    $.fn.autocompleteTextField = function(options) {
        return this.each(function() {
            // jQuery object for the input field
            var $field = $('#' + options.elementParamName);
            // Container for the autocomplete dropdown list
            var $container = $field.closest('.autocomplete-field-container').find('.autocomplete-list-container');
            // Tracks how many items have been loaded so far
            var lastCount = 0;
            // Current search query
            var query = '';
            // Flags to control API calls and UI state
            var endOfResult = false;      // True if all autocomplete results have been loaded
            var blockApiResponse = false; // Prevents response post process if dropdown is already hidden
            var ongoingApiCall = false;   // Prevents duplicate API calls during scroll

            // Hides the dropdown and clears its contents
            function hideList() {
                $container.addClass('hide');
                $container.find('ul').html('');
            }

            // Calls the backend API to fetch autocomplete results
            // newQuery: true if this is a new search, false if loading more
            function callAPI(newQuery = true) {
                if (!query) {
                    hideList();
                    return;
                }
                if (newQuery) {
                    lastCount = 0;
                    $container.find('ul').html('');
                } else {
                    lastCount = lastCount + options.itemsPerLoad;
                }
                // Prepare form data for AJAX request
                var formData = new FormData();
                formData.append('_query', query);
                formData.append('_lastCount', lastCount);
                formData.append('_itemsPerLoad', options.itemsPerLoad);
                formData.append('_elementParamName', options.elementParamName);
                $.ajax({
                    url: '/jw/web/json/plugin/org.joget.marketplace.AutocompleteTextField/service',
                    method: 'POST',
                    data: formData,
                    contentType: false,
                    processData: false,
                    success: function(response) {
                        // Ignore the response if dropdown has been hidden
                        // Because user might suddenly close the dropdown while it's fetching
                        // So we don't want the dropdown to open again 
                        if (blockApiResponse) return; 
                        // Extract data from response and mark API call as completed
                        var autocompleteStatus = response.autocompleteStatus;
                        var autocompleteResult = response.autocompleteResult;
                        ongoingApiCall = false;
                        // Update endOfResult flag based on server response
                        if (autocompleteStatus == 'END_OF_RESULT') {
                            endOfResult = true;
                        } else {
                            endOfResult = false;
                        }
                        // Hide dropdown if no results
                        if (autocompleteStatus == 'NO_RESULT') {
                            $container.addClass('hide');
                        } else {
                            // Remove loading indicator and show results
                            $container.find('ul').find('#loading-indicator').remove();
                            $container.removeClass('hide');
                            // Render each result as a list item
                            autocompleteResult.forEach(function(item, index) {
                                var $li = $('<li></li>')
                                    .text(item.label)
                                    .attr('value', item.value);
                                if (index === autocompleteResult.length - 1) {
                                    $li.addClass('no-border-bottom');
                                }
                                $container.find('ul').append($li);
                            });
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error(error);
                    }
                });
            }

            // Show suggestions when the field is clicked
            $field.on('click', function() {
                blockApiResponse = false;
                if (!$container.hasClass('hide')) return;
                query = $field.val();
                callAPI();
            });

            // Fetch new suggestions as the user types
            $field.on('input', function() {
                query = $field.val();
                callAPI();
            });

            // Load more results when scrolled to bottom
            $container.on('scroll', function() {
                var scrollTop = $container.scrollTop();
                var scrollHeight = $container[0].scrollHeight;
                var containerHeight = $container.innerHeight();
                var listContainerClosed = (scrollTop === 0 && scrollHeight === 0 && containerHeight === 0);
                var scrolledToBottom = (scrollHeight - containerHeight == scrollTop);
                if (scrolledToBottom && !ongoingApiCall && !listContainerClosed) {
                    if (!endOfResult) {
                        // Show loading indicator while fetching more
                        if ($container.find('#loading-indicator').length == 0) {
                            var $li = $('<li></li>')
                                .attr('id', 'loading-indicator')
                                .text('...');
                            $container.find('ul').append($li);
                        }
                        setTimeout(function() {
                            ongoingApiCall = true;
                            callAPI(false);
                        }, 1000); // Simulate delay for UX, so user can see the loading indicator
                    }
                }
            });

            // Handle user selection from the dropdown
            $container.on('click', 'li', function() {
                if ($(this).attr('id') != 'loading-indicator') {
                    $field.val($(this).text());
                    var selectedValue = $(this).attr('value');
                    // If configured, set value to the field specified in "Field ID to Store Selection Value"
                    if (options.selectionIdSelector) {
                        $(options.selectionIdSelector).val(selectedValue);
                    }
                    hideList();
                }
            });

            // Hide dropdown when clicking outside the field or list
            $(document).on('click', function(event) {
                var $target = $(event.target);
                if (!$target.closest($container).length && !$target.closest($field).length) {
                    blockApiResponse = true;
                    hideList();
                }
            });
        });
    };
})(jQuery); 