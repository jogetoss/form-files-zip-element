package org.joget.marketplace;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;

import org.joget.apps.form.lib.SelectBox;
import org.joget.apps.form.model.FormBuilderPalette;
import org.joget.plugin.base.PluginWebSupport;
import org.springframework.context.ApplicationContext;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import javax.servlet.http.HttpServletRequest;

import org.joget.apps.app.dao.FormDefinitionDao;
import org.joget.apps.app.model.AppDefinition;
import org.joget.apps.app.model.FormDefinition;
import org.joget.apps.app.service.AppPluginUtil;
import org.joget.apps.app.service.AppService;
import org.joget.apps.app.service.AppUtil;
import org.joget.apps.form.model.FormData;
import org.joget.apps.form.model.FormRow;
import org.joget.apps.form.model.FormRowSet;
import org.joget.apps.form.service.FileUtil;
import org.joget.apps.form.service.FormUtil;
import org.joget.commons.util.LogUtil;
import org.joget.commons.util.ResourceBundleUtil;

public class FormFilesZipElement extends SelectBox implements PluginWebSupport {
    public static String MESSAGE_PATH = "message/FormFilesZipElement";
    
    @Override
    public String getName() {
        return AppPluginUtil.getMessage("org.joget.marketplace.formfileszipelement.name", getClassName(), MESSAGE_PATH);

    }

    @Override
    public String getVersion() {
        return "8.0.0";
    }

    @Override
    public String getDescription() {
        return AppPluginUtil.getMessage("org.joget.marketplace.formfileszipelement.desc", getClassName(), MESSAGE_PATH);
    }
    
    @Override
    public String getClassName() {
        return getClass().getName();
    }

    @Override
    public String getFormBuilderTemplate() {
        return "<label class='label'>" + getLabel() + "</label><button onclick='return false;'>" + ResourceBundleUtil.getMessage("form.formfileszipelement.selectlabel") + "</button>";
    }

    @Override
    public String getLabel() {
        return AppPluginUtil.getMessage("org.joget.marketplace.formfileszipelement.label", getClassName(), MESSAGE_PATH);
    }
    
    @Override
    public String getPropertyOptions() {
        String json = AppUtil.readPluginResource(getClass().getName(), "/properties/FormFilesZipElement.json", null, true, MESSAGE_PATH);
        return json;
    }
    
    @Override
    public String getFormBuilderCategory() {
        return FormBuilderPalette.CATEGORY_CUSTOM;
    }

    @Override
    public int getFormBuilderPosition() {
        return 350;
    }
    
    @Override
    public String renderTemplate(FormData formData, Map dataModel) {
        String template = "FormFilesZipElement.ftl";

        AppDefinition appDef = AppUtil.getCurrentAppDefinition();
        dataModel.put("appId", appDef.getAppId());
        dataModel.put("appVersion", appDef.getVersion().toString());

        Object downloadFields = getProperty("downloadFields");
        if (downloadFields != null && downloadFields instanceof Object[]) {
            String downloadFieldsStr = "";
            for (Object param : ((Object[]) downloadFields)) {
                Map paramMap = ((Map)param);

                if (downloadFieldsStr.length() > 1) {
                    downloadFieldsStr += ",";
                }
              
                downloadFieldsStr += paramMap.get("field");
            }
            dataModel.put("downloadFieldsStr", downloadFieldsStr);
        } else {
            dataModel.put("downloadFieldsStr", "");
        }

        if(formData.getPrimaryKeyValue()!=null){
            dataModel.put("recordId", formData.getPrimaryKeyValue());
        } else {
            dataModel.put("recordId", "");
        }

        String html = FormUtil.generateElementHtml(this, formData, template, dataModel);
        return html;
        
    }


    @Override
    public void webService(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String formDefId = request.getParameter("formDefId");
        String recordId = request.getParameter("recordId");
        String download = request.getParameter("download");;
        String downloadFields = request.getParameter("downloadFields");;

        ApplicationContext ac = AppUtil.getApplicationContext();
        AppService appService = (AppService) ac.getBean("appService");
        AppDefinition appDef = AppUtil.getCurrentAppDefinition();
        FormDefinitionDao dao = (FormDefinitionDao) FormUtil.getApplicationContext().getBean("formDefinitionDao");
        FormDefinition formDef = dao.loadById(formDefId, appDef);
        
        String[] uploadFieldIdsArr = new String[0];
        if(download.equals("downloadAll")){
            // get all upload field ids
            String json = formDef.getJson();
            String uploadFieldIds = findUploadFieldIds(formDefId, json);
            uploadFieldIdsArr = uploadFieldIds.split(",");
        } else if(download.equals("downloadSelectedFields")){
            String uploadFieldIds = downloadFields;
            uploadFieldIdsArr = uploadFieldIds.split(",");
        }
      
        // get files from upload field ids
        FormRowSet set = appService.loadFormData(appDef.getAppId(), appDef.getVersion().toString(), formDefId,recordId);
        FormRow row = set.get(0);

        // Get excel file
        List<String> fileNamesList = new ArrayList<>();
        for(String uploadFieldId : uploadFieldIdsArr){
            if (uploadFieldId != null && !uploadFieldId.equals("")) {
                if (!row.get(uploadFieldId).toString().isEmpty()) {
                    // Get files name
                    String filesName = row.get(uploadFieldId).toString();
                    String[] fileNames = filesName.split(";");
                    for (String s : fileNames) {
                        fileNamesList.add(s);
                    }
                    
                } else {
                    LogUtil.info(getClassName(), "Form Row not found for ID: " + recordId);
                }
            }
        }

        // Zip all excel files into 1 zip file
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
  
        try (ZipOutputStream zos = new ZipOutputStream(byteArrayOutputStream)) {

            // Buffer for reading the file
            byte[] buffer = new byte[1024];

            Boolean fileAddedToZip = false;
            // Iterate over each file name
            for (String fileName : fileNamesList) {
                // Get the file
                File file = FileUtil.getFile(fileName.trim(), appService.getFormTableName(appDef, formDefId), recordId);

                if (file != null && file.exists()) {
                    // Add a new entry to the zip file
                    ZipEntry zipEntry = new ZipEntry(fileName.trim());
                    zos.putNextEntry(zipEntry);

                    // Read the file and write it to the zip output stream
                    try (FileInputStream fis = new FileInputStream(file)) {
                        int length;
                        while ((length = fis.read(buffer)) > 0) {
                            zos.write(buffer, 0, length);
                        }
                    }
                    fileAddedToZip = true;
                    // Close the current entry
                    zos.closeEntry();

                } else {
                    LogUtil.info(getClassName(), "File not found: " + fileName);
                }
            }
            
            if(fileAddedToZip){
                LogUtil.info(getClassName(), "Files have been zipped successfully!");

                // Set the response headers
                response.setContentType("application/zip");
                response.setHeader("Content-Disposition", "attachment; filename=files.zip");
    
                // Write the zip data to the response output stream
                try (ServletOutputStream servletOutputStream = response.getOutputStream()) {
                    byteArrayOutputStream.writeTo(servletOutputStream);
                    servletOutputStream.flush();
                }
            }
        
        } catch (IOException e) {
            LogUtil.error("Zip File", e, e.getMessage());
        }
    }

    private String findUploadFieldIds(String formDefId, String json){
        Gson gson = new Gson();

        // Parse the JSON string into a JsonObject
        JsonObject jsonObject = gson.fromJson(json, JsonObject.class);
        String id = "";
        // Navigate through elements array
        JsonArray elementsArray = jsonObject.getAsJsonArray("elements");
        for (JsonElement sectionElement : elementsArray) {
            JsonObject sectionObject = sectionElement.getAsJsonObject();
            JsonArray sectionElementsArray = sectionObject.getAsJsonArray("elements");
            for (JsonElement columnElement : sectionElementsArray) {
                JsonObject columnObject = columnElement.getAsJsonObject();
                JsonArray columnElementsArray = columnObject.getAsJsonArray("elements");
                for (JsonElement uploadElement : columnElementsArray) {
                    JsonObject uploadObject = uploadElement.getAsJsonObject();
                    // Check if className contains "Upload"
                    String className = uploadObject.getAsJsonPrimitive("className").getAsString();
                    if (className.contains("Upload")) {
                        // Print or process the id of the element
                        id += uploadObject.getAsJsonObject("properties").getAsJsonPrimitive("id").getAsString() + ",";
                    }
                }
            }
        }
        return id;
    }
}