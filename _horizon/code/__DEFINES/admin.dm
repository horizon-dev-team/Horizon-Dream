#define CLIENT_HAS_RIGHTS(cli, flags) ((cli?.holder?.check_for_rights(flags)) == TRUE)
#define CLIENT_IS_STAFF(cli) (cli?.holder && check_rights_for(cli, R_ADMIN))
#define CLIENT_IS_MENTOR(cli) CLIENT_HAS_RIGHTS(cli, R_MENTOR) || CLIENT_IS_STAFF(cli)

#define ADMIN_TAB "admin"
#define MENTOR_TAB "mentor"
