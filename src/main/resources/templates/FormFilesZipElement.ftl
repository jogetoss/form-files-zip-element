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
    <button id="${elementParamName!}" name="${elementParamName!}" class="form-button btn button btn-primary">
        ${element.properties.buttonLabel!}
    </button>
</div>

<!-- Fancy Google-Drive-Style Popup Modal -->
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
                <table>
                    <thead>
                        <tr>
                            <th class="name-column">Name</th>
                            <th class="size-column">Size</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td class="name-cell">
                                <label class="file-row">
                                    <input type="checkbox" class="file-checkbox" value="file1.zip">
                                    <span class="file-name">file1.zip</span>
                                </label>
                            </td>
                            <td>2.3 MB</td>
                        </tr>
                        <tr>
                            <td class="name-cell">
                                <label class="file-row">
                                    <input type="checkbox" class="file-checkbox" value="file2.zip">
                                    <span class="file-name">file2.zip</span>
                                </label>
                            </td>
                            <td>1.8 MB</td>
                        </tr>
                        <tr>
                            <td class="name-cell">
                                <label class="file-row">
                                    <input type="checkbox" class="file-checkbox" value="file3.zip">
                                    <span class="file-name">file3.zip</span>
                                </label>
                            </td>
                            <td>3.1 MB</td>
                        </tr>
                        <tr>
                            <td class="name-cell">
                                <label class="file-row">
                                    <input type="checkbox" class="file-checkbox" value="file4.zip">
                                    <span class="file-name">file4.zip</span>
                                </label>
                            </td>
                            <td>4.7 MB</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
        <div class="popup-footer">
            <button id="downloadSelected" class="btn-download">
                <i class="fas fa-download"></i> Download Selected Files
            </button>
        </div>
    </div>
</div>

<!-- Optional: Font Awesome for icons -->
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

<style>
/* Base Modal State */
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

/* Visible Modal */
.popup-modal.show {
    opacity: 1;
    visibility: visible;
    pointer-events: auto;
}

/* Modal Box */
.popup-content {
    background: rgba(255, 255, 255, 0.97);
    border-radius: 16px;
    padding: 25px 30px;
    width: 50vw;
    max-width: 900px;
    min-width: 320px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
    animation: scaleIn 0.25s ease;
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
    max-height: 340px;
    overflow-y: auto;
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

/* Table Styling */
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
.file-row input[type="checkbox"] {
    transform: scale(1.1);
}
.file-name {
    color: #333;
    font-weight: 500;
}
.file-list-table td {
    padding: 8px 12px;
    border-bottom: 1px solid #f0f0f0;
}
.file-list-table tr:hover {
    background-color: #f5faff;
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
</style>

<script>
$(document).ready(function() {
    // Open popup
    $("#${elementParamName!}").click(function(event) {
        event.preventDefault();
        $("#popupModal").addClass("show");
    });

    // Close popup
    $("#closePopup").click(function() {
        $("#popupModal").removeClass("show");
    });

    // Close popup on background click
    $("#popupModal").click(function(e) {
        if ($(e.target).is("#popupModal")) {
            $("#popupModal").removeClass("show");
        }
    });

    // Select all checkbox logic
    $("#selectAll").change(function() {
        $(".file-checkbox").prop("checked", this.checked);
    });

    $(".file-checkbox").change(function() {
        if (!this.checked) {
            $("#selectAll").prop("checked", false);
        } else if ($(".file-checkbox:checked").length === $(".file-checkbox").length) {
            $("#selectAll").prop("checked", true);
        }
    });

    // Download selected files (placeholder)
    $("#downloadSelected").click(function() {
        const selected = $(".file-checkbox:checked").map(function() {
            return $(this).val();
        }).get();

        if (selected.length === 0) {
            alert("Please select at least one file to download.");
        } else {
            alert("Preparing to download:\n" + selected.join("\n"));
            // Real download logic would be implemented here
        }
    });
});
</script>
</div>
