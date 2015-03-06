<%@ page import="java.net.MalformedURLException,
                 java.util.*,
                 org.apache.commons.fileupload.DiskFileUpload,
                 org.apache.commons.fileupload.FileItem,
                 org.tttalk.openfire.plugin.TTTalkUserBatchPlugin,
                 org.jivesoftware.openfire.XMPPServer,
                 org.jivesoftware.util.ParamUtils"
%>

<%
	boolean createUsers = request.getParameter("createUsers") != null;
	boolean importUsers = request.getParameter("importUsers") != null;
   
    TTTalkUserBatchPlugin plugin = (TTTalkUserBatchPlugin) XMPPServer.getInstance().getPluginManager().getPlugin("tttalk.userbatch");
    List<String> duplicateUsers = new ArrayList<String>();
   
    Map<String, String> errors = new HashMap<String, String>();
    if (createUsers) {
    	String data = request.getParameter("data");
    	if (data.trim().length() == 0){
    		errors.put("emptyData", "emptyData");
    	}else{
        	duplicateUsers.addAll(plugin.createUsers(data));
        	
        	if (duplicateUsers.size() == 0) {
                response.sendRedirect("create-users.jsp?success=true");
                return;
            }
            
            errors.put("invalidUser", "invalidUser");
    	}        
	} else if (importUsers) {
        DiskFileUpload dfu = new DiskFileUpload();
      
        List fileItems = dfu.parseRequest(request);
        Iterator i = fileItems.iterator();
        FileItem fi = (FileItem) i.next();
        plugin.importUserData(fi);
        response.sendRedirect("create-users.jsp?success=true");
	}
%>

<html>
    <head>
        <title>Create TTTalk User Data</title>
        <meta name="pageID" content="tttalk-create"/>
    </head>
    <style>
	    ::-webkit-input-placeholder::before {
		  content: "username_1,password_1\000Ausername_2,password_2\000Ausername_3,password_3";
		}
		
		::-moz-placeholder::before {
		  content: "username_1,password_1\000Ausername_2,password_2\000Ausername_3,password_3";
		}
		
		:-ms-input-placeholder::before {
		  content: "username_1,password_1\000Ausername_2,password_2\000Ausername_3,password_3";
		}
    </style>
    <body>

<% if (errors.size() > 0) { %>

    <div class="jive-error">
    <table cellpadding="0" cellspacing="0" border="0">
        <tbody>
        <tr>
            <td class="jive-icon"><img src="images/error-16x16.gif" width="16" height="16" border="0"></td>
            <td class="jive-icon-label">
            <% if (errors.containsKey("emptyData")) { %>
               Please input username and password list.<br>
            <% }else if (errors.containsKey("invalidUser")) { %>
                
                <% if (plugin.isUserProviderReadOnly()) { %>
                   The following users did not exist in the system or have invalid username so their roster was not loaded:<br>
                <% } else { %>
                   The following users already exist in the system or have invalid username and were not loaded:<br>
                <% } %>
            <%
                Iterator iter = duplicateUsers.iterator();
                while (iter.hasNext()) {
                    String username = (String) iter.next();
                    %><%= username %><%
                    if (iter.hasNext()) {
                        %>,&nbsp;<%
                    } else {
                        %>.<%
                    }
                }
            } %>
            </td>
        </tr>
        </tbody>
    </table>
    </div>
    <br>

<% } else if (ParamUtils.getBooleanParameter(request, "success")) { %>

    <div class="jive-success">
    <table cellpadding="0" cellspacing="0" border="0">
        <tbody>
        <tr>
            <td class="jive-icon"><img src="images/success-16x16.gif" width="16" height="16" border="0"></td>
            <% if (plugin.isUserProviderReadOnly()) { %>
               <td class="jive-icon-label">User roster data added successfully.</td>
            <% } else { %>
               <td class="jive-icon-label">All users added successfully.</td>
            <% } %>
        </tr>
        </tbody>
    </table>
    </div>
    <br>

<% } %>

<form action="create-users.jsp?createUsers=true" method="post" >

<div class="jive-contentBoxHeader">Create</div>
<div class="jive-contentBox">
    <textarea name="data" rows="10" style="width:50%" placeholder=" "></textarea>
</div>
<input type="submit" value="Create">

</form>



<form action="create-users.jsp?importUsers=true" method="post" enctype="multipart/form-data">
	<div class="jive-contentBoxHeader">Import</div>
	<div class="jive-contentBox">
	    Choose a file to import:</p>
	    <input type="file" name="thefile">
	</div>
	<input type="submit" value="Import">

</form>

</body>
</html>

