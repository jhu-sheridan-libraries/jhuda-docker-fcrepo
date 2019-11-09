package env

import "os"

type FcrepoEnv struct {
	BaseUri,
	Port,
	User,
	Password,
	DataDir,
	SpAuthHeader,
	SpAuthRoles,
	AuthRealm,
	ModeConfig,
	LogLevel,
	AuthLogLevel,
	PublicBaseUri string
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
		SpAuthHeader: os.ExpandEnv("${FCREPO_SP_AUTH_HEADER"),
		SpAuthRoles:  os.ExpandEnv("${FCREPO_AUTH_ROLES}"),
		AuthRealm:    os.ExpandEnv("${FCREPO_AUTH_REALM}"),
		ModeConfig:   os.ExpandEnv("${FCREPO_MODESHAPE_CONFIG}"),
		LogLevel:     os.ExpandEnv("${FCREPO_LOGLEVEL}"),
		AuthLogLevel: os.ExpandEnv("${FCREPO_AUTH_LOGLEVEL}"),
		// Note the following env var is for testing only, *not* present or used in the production image
		PublicBaseUri: os.ExpandEnv("${PUBLIC_BASE_URI}"),
	}
}
