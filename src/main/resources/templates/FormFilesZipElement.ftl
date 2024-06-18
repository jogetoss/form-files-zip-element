<div class="form-cell" ${elementMetaData!}>
<#if (element.properties.showLabel! == 'true') >
    <label class="label" field-tooltip="${elementParamName!}">${element.properties.label} <span class="form-cell-validator">${decoration}</span><#if error??> <span class="form-error-message">${error}</span></#if></label>
</#if>
    <div class="form-cell-value" id="formfilezzip_${elementParamName!}_${element.properties.elementUniqueKey!}">
        <button id="${elementParamName!}" name="${elementParamName!}" class="form-button btn button btn-primary">${element.properties.buttonLabel!}</button>
    </div>

<script>
$(document).ready(function() {
    $("#${elementParamName!}").click(function(event) {
        event.preventDefault(); // Prevent the default form submission
        $.ajax({
            type: "POST",
            url: "${element.serviceUrl!}",
            data: {
                id: '${id}'
            },
            xhrFields: {
                responseType: 'blob' // Set response type to blob for binary data
            },
            success: function(response, status, xhr) {
                var blob = new Blob([response], { type: 'application/zip' });
                var link = document.createElement('a');
                link.href = URL.createObjectURL(blob);
                window.location = link;
            },
            error: function(xhr, status, error) {
                alert("No files to be zipped.");
            }
        });
    });
});

</script>
</div>
