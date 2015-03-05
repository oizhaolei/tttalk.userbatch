package org.tttalk.openfire.plugin;

import gnu.inet.encoding.Stringprep;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.jivesoftware.openfire.XMPPServer;
import org.jivesoftware.openfire.container.Plugin;
import org.jivesoftware.openfire.container.PluginManager;
import org.jivesoftware.openfire.user.User;
import org.jivesoftware.openfire.user.UserManager;
import org.jivesoftware.openfire.user.UserProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TTTalkUserBatchPlugin implements Plugin {

	private static final Logger log = LoggerFactory
			.getLogger(TTTalkUserBatchPlugin.class);

	private UserManager userManager;
	private UserProvider provider;

	public TTTalkUserBatchPlugin() {
		userManager = XMPPServer.getInstance().getUserManager();
		provider = UserManager.getUserProvider();
		XMPPServer.getInstance().getServerInfo().getXMPPDomain();
	}

	@Override
	public void initializePlugin(PluginManager manager, File pluginDirectory) {
	}

	@Override
	public void destroyPlugin() {
		userManager = null;
		provider = null;
	}

	public List<String> createUsers(String userData) {
		List<String> invalidUsers = new ArrayList<String>();

		String[] lines = userData.split("\n");

		int create = 0;
		int error = 0;

		for (int i = 0; i < lines.length; i++) {
			String[] temp = lines[i].split(",");
			String userName = temp[0].trim();
			String password = temp[1].trim();

			if ((userName != null) && (password != null)) {
				try {
					userName = Stringprep.nodeprep(userName);

					if (!provider.isReadOnly()) {
						userManager.createUser(userName, password, null, null);
						log.info("createUser: " + userName + "," + password);
					}

					// Check to see user exists before adding their roster, this
					// is for read-only user providers.
					userManager.getUser(userName);
					create++;
				} catch (Exception e) {
					error++;
					log.error(e.getMessage());
					invalidUsers.add(userName);
				}
			}
		}
		log.info("createUsers create: " + create + ", error:" + error);

		return invalidUsers;
	}

	public void deleteUsers(String str) {
		String[] usernames = str.split("\n");

		// RosterManager rosterManager = server.getRosterManager();
		log.info("Deleting users accounts: " + usernames.length);
		int delete = 0;
		int error = 0;
		for (String username : usernames) {
			try {
				username = username.trim();
				User user = userManager.getUser(username);

				// deleteRosters(user, rosterManager);
				userManager.deleteUser(user);
				log.info("deleteUser: " + username);
				delete++;
			} catch (Exception e) {
				error++;
				log.error(e.getMessage());
			}
		}
		log.info("deleteUsers deleted: " + delete + ", error:" + error);
	}
}
