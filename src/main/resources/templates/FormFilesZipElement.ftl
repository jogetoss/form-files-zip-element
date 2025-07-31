<div class="form-cell" ${elementMetaData!}>
<#if (element.properties.showLabel! == 'true') >
    <label class="label" field-tooltip="${elementParamName!}">
        ${element.properties.label}
        <span class="form-cell-validator">${decoration}</span>
        <#if error??>
            <span class="form-error-message">${error}</span>
        </#if>
    </label>
</#if>
<div class="form-cell-value" id="formfilezzip_${elementParamName!}_${element.properties.elementUniqueKey!}">
    <div class="container">
        <div class="description">
            ${element.properties.label!}
        </div>
        <div class="icon">
            <a href="#" id="${elementParamName!}" name="${elementParamName!}" title="${element.properties.buttonLabel!}">
                <i class="fas fa-download fa-2x" aria-hidden="true"></i>
            </a>
        </div>
    </div>
</div>

</div>

<!-- Popup Modal -->
<div id="popupModal" class="popup-modal">
    <div class="popup-content">
        <div class="popup-header">
            <h2><i class="fa fa-file-archive-o" aria-hidden="true"></i> Select Files to Download</h2>
            <span id="closePopup" class="popup-close">&times;</span>
        </div>
        <div class="popup-body">
            <label class="select-all">
                <input type="checkbox" id="selectAll"> <strong>Select All</strong>
            </label>
            <div class="file-list-table">
                <div class="table-scroll">
                    <table>
                        <thead>
                            <tr>
                                <th class="name-column">Name</th>
                                <th class="size-column">Size</th>
                            </tr>
                        </thead>
                        <tbody id="filesTableBody">
                            <tr id="loadingRow">
                                <td colspan="2" style="text-align: center; padding: 20px;">
                                    <i class="fa fa-spinner fa-spin"></i> Loading files...
                                </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <div class="popup-footer">
            <button id="downloadSelected" class="btn-download">
                <i class="fas fa-download"></i> Download Selected Files
            </button>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    // Open popup
    $("#${elementParamName!}").click(function(event) {
        event.preventDefault();
        $("#popupModal").addClass("show");
        loadFiles();
    });

    // Close popup
    $("#closePopup").click(function() {
        $("#popupModal").removeClass("show");
    });

    // Close when clicking outside content
    $("#popupModal").click(function(e) {
        if ($(e.target).is("#popupModal")) {
            $("#popupModal").removeClass("show");
        }
    });

    // Select all toggle
    $("#selectAll").change(function() {
        $(".file-checkbox").prop("checked", this.checked);
    });

    // Sync "Select All" checkbox with individual selections
    $(".file-checkbox").change(function() {
        const allChecked = $(".file-checkbox").length === $(".file-checkbox:checked").length;
        $("#selectAll").prop("checked", allChecked);
    });

    // Download button logic
    $("#downloadSelected").click(function() {
        const selected = $(".file-checkbox:checked").map(function() {
            return $(this).val();
        }).get();

        if (selected.length === 0) {
            alert("Please select at least one file to download.");
        } else {
            // Trigger the actual download
            downloadSelectedFiles(selected);
        }
    });

    // Function to load files from the endpoint
    function loadFiles() {
        const serviceUrl = "${element.getServiceUrl()}";
        const listUrl = serviceUrl + "&action=list&id=${id!}";
        
        $.ajax({
            url: listUrl,
            method: 'GET',
            dataType: 'json',
            success: function(data) {
                populateFilesTable(data);
            },
            error: function(xhr, status, error) {
                console.error('Error loading files:', error);
                $("#filesTableBody").html('<tr><td colspan="2" style="text-align: center; color: red; padding: 20px;">Error loading files. Please try again.</td></tr>');
            }
        });
    }

    // Function to populate the files table
    function populateFilesTable(files) {
        const tbody = $("#filesTableBody");
        tbody.empty();
        
        if (files && files.length > 0) {
            files.forEach(function(file) {
                const row = $('<tr>');
                row.append('<td class="name-cell">' +
                    '<label class="file-row">' +
                        '<input type="checkbox" class="file-checkbox" value="' + file.fileName + '">' +
                        '<span class="file-name">' + file.fileName + '</span>' +
                    '</label>' +
                '</td>' +
                '<td>' + (file.fileSize || 'Unknown') + '</td>');
                tbody.append(row);
            });
            
            // Re-bind the checkbox change event for new elements
            $(".file-checkbox").off('change').on('change', function() {
                const allChecked = $(".file-checkbox").length === $(".file-checkbox:checked").length;
                $("#selectAll").prop("checked", allChecked);
            });
        } else {
            tbody.html('<tr><td colspan="2" style="text-align: center; padding: 20px;">No files found.</td></tr>');
        }
    }

    // Function to download selected files
    function downloadSelectedFiles(selectedFiles) {
        const serviceUrl = "${element.getServiceUrl()}";
        
        // Create a form to submit the download request
        const form = $('<form>', {
            'method': 'POST',
            'action': serviceUrl,
            'target': '_blank'
        });
        
        // Add the selected files as hidden inputs
        selectedFiles.forEach(function(fileName) {
            form.append($('<input>', {
                'type': 'hidden',
                'name': 'selectedFiles',
                'value': fileName
            }));
        });
        
        // Add the record ID
        form.append($('<input>', {
            'type': 'hidden',
            'name': 'id',
            'value': '${id!}'
        }));
        
        // Submit the form
        $('body').append(form);
        form.submit();
        form.remove();
    }
});
</script>


<!-- Font Awesome for icons -->
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

<style>
/* Modal Overlay */
.popup-modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    backdrop-filter: blur(5px);
    background-color: rgba(0, 0, 0, 0.6);
    opacity: 0;
    visibility: hidden;
    pointer-events: none;
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
    transition: opacity 0.3s ease, visibility 0.3s ease;
}

/* Show modal */
.popup-modal.show {
    opacity: 1;
    visibility: visible;
    pointer-events: auto;
}

/* Modal Content Box */
.popup-content {
    background: rgba(255, 255, 255, 0.95);
    border-radius: 16px;
    padding: 25px 30px;
    width: 50vw;
    max-width: 800px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
    animation: scaleIn 0.3s ease;
    display: flex;
    flex-direction: column;
    position: relative;
}

/* Header */
.popup-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
}
.popup-header h2 {
    font-size: 20px;
    margin: 0;
    display: flex;
    align-items: center;
    gap: 10px;
    color: #333;
}
.popup-close {
    font-size: 26px;
    cursor: pointer;
    color: #999;
    transition: color 0.3s;
}
.popup-close:hover {
    color: #ff4d4d;
}

/* Body */
.popup-body {
    flex-grow: 1;
    margin-bottom: 20px;
}
.select-all {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 12px;
    font-weight: 500;
    color: #444;
}

/* Scrollable table */
.file-list-table .table-scroll {
    max-height: 240px;
    overflow-y: auto;
    border: 1px solid #eee;
    border-radius: 6px;
}
.file-list-table table {
    width: 100%;
    border-collapse: collapse;
    font-size: 14px;
}
.file-list-table thead {
    border-bottom: 1px solid #ddd;
}
.file-list-table th {
    text-align: left;
    color: #777;
    padding: 10px 12px;
    font-weight: 500;
    font-size: 13px;
    background: #f9f9f9;
    position: sticky;
    top: 0;
    z-index: 1;
}
.file-list-table td {
    padding: 8px 12px;
    border-bottom: 1px solid #f0f0f0;
}
.file-list-table tr:hover {
    background-color: #f5faff;
}
.name-cell {
    padding: 8px 12px;
}
.file-row {
    display: flex;
    align-items: center;
    gap: 12px;
    cursor: pointer;
}
.file-name {
    color: #333;
    font-weight: 500;
}
.file-row input[type="checkbox"] {
    transform: scale(1.1);
}
.size-column {
    width: 120px;
}

/* Footer */
.popup-footer {
    text-align: right;
}
.btn-download {
    background: linear-gradient(to right, #4a90e2, #007bff);
    color: white;
    border: none;
    padding: 10px 20px;
    font-weight: 500;
    border-radius: 8px;
    cursor: pointer;
    transition: background 0.3s;
}
.btn-download:hover {
    background: linear-gradient(to right, #007bff, #0056b3);
}

/* Animations */
@keyframes scaleIn {
    from { transform: scale(0.95); opacity: 0; }
    to { transform: scale(1); opacity: 1; }
}

/* Loading spinner */
.fa-spinner {
    color: #007bff;
    font-size: 18px;
}

/* Error message styling */
.file-list-table td[colspan="2"] {
    color: #dc3545;
    font-style: italic;
}

/* No files message */
.file-list-table td[colspan="2"]:not([style*="color: red"]) {
    color: #6c757d;
    font-style: italic;
}
   .container {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 10px;
        border: 1px solid #ccc;
        border-radius: 8px;
        background-color: #f9f9f9;
        margin-top: 10px;
    }
    .description {
        flex-grow: 1;
        margin-right: 15px;
        font-size: 15px;
        color: #333;
    }
    .icon img {
        width: 36px;
        height: 36px;
        cursor: pointer;
    }
</style>
</div>
