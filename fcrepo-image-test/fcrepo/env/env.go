package env

import "os"

type FcrepoEnv struct {
	// base http uri of the fedora repository rest api
	BaseUri,
	// port that the servlet container listens on
	Port,
	// user that has admin privileges to the fedora repository
	User,
	// password granting admin privileges to the fedora repository
	Password,
	// the directory within the docker container (perhaps mounted from a volume) used to persist fedora data
	DataDir,
	// header set by the shibboleth service provider identifying the authenticated user,
	// used by the jetty-shib-authenticator
	SpAuthHeader,
	// roles that shibboleth authenticated users belong to, comma delimited, used by the jetty-shib-authenticator
	SpAuthRoles,
	// name of the basic authentication realm that protects fedora (corresponds to the realm name of the login service
	// in fedora's web.xml)
	AuthRealm,
	// Spring Resource URI identifying the ModeShape Spring configuration
	ModeConfig,
	// log level used by Fedora
	LogLevel,
	// log level used by the Authentication-related classes of Fedora
	AuthLogLevel,
	// public URI of the Fedora repository rest api
	PublicBaseUri,
	// shibboleth service provider URI that proxies the Fedora base URI
	SpProxyUri string
}

// answers a struct containing known Docker environment variables used by the
// jhuda/fcrepo image
func New() FcrepoEnv {
	return FcrepoEnv{
		BaseUri:      os.ExpandEnv("${FCREPO_BASE_URI}"),
		Port:         os.ExpandEnv("${FCREPO_JETTY_PORT}"),
		User:         os.ExpandEnv("${FCREPO_USER}"),
		Password:     os.ExpandEnv("${FCREPO_PASS}"),
		DataDir:      os.ExpandEnv("${FCREPO_DATA_DIR}"),
		SpAuthHeader: os.ExpandEnv("${FCREPO_SP_AUTH_HEADER}"),
		SpAuthRoles:  os.ExpandEnv("${FCREPO_SP_AUTH_ROLES}"),
		AuthRealm:    os.ExpandEnv("${FCREPO_AUTH_REALM}"),
		ModeConfig:   os.ExpandEnv("${FCREPO_MODESHAPE_CONFIG}"),
		LogLevel:     os.ExpandEnv("${FCREPO_LOGLEVEL}"),
		AuthLogLevel: os.ExpandEnv("${FCREPO_AUTH_LOGLEVEL}"),
		// Note the following env vars are for testing only, *not* present or used in the production image
		PublicBaseUri: os.ExpandEnv("${PUBLIC_BASE_URI}"),
		SpProxyUri: os.ExpandEnv("${SP_PROXY_URI}"),
	}
}
