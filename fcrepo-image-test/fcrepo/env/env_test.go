package env

import (
	"github.com/stretchr/testify/assert"
	"net/url"
	"strconv"
	"strings"
	"testing"
)

var fcrepoEnv = New()

// FCREPO_JETTY_PORT should be an integer greater than 0 and less than 2^16
func Test_JettyPort(t *testing.T) {
	assert.True(t, len(fcrepoEnv.Port) > 0)
	val, err := strconv.Atoi(fcrepoEnv.Port)
	assert.Nil(t, err)
	assert.True(t, 0 < val && val < 1<<16)
}

// FCREPO_BASE_URI should be a url, and contain the value of FCREPO_JETTY_PORT
func Test_BaseUriContainsJettyPort(t *testing.T) {
	assert.True(t, len(fcrepoEnv.BaseUri) > 0)
	u, err := url.Parse(fcrepoEnv.BaseUri)
	assert.Nil(t, err)
	assert.EqualValues(t, fcrepoEnv.Port, u.Port())
}

// In our instance, the fcrepoEnv username and password are required for basic auth and
// must have a value.
func Test_NotNilUserAndPass(t *testing.T) {
	assert.True(t, len(fcrepoEnv.User) > 0)
	assert.True(t, len(fcrepoEnv.Password) > 0)
}

// SP_PROXY_URI should be a url
func Test_SpProxyUri(t *testing.T) {
	assert.True(t, len(fcrepoEnv.SpProxyUri) > 0)
	_, err := url.Parse(fcrepoEnv.SpProxyUri)
	assert.Nil(t, err)
}

// User should not be null and non-empty
func Test_User(t *testing.T) {
	assert.NotNil(t, fcrepoEnv.User)
	assert.True(t, len(strings.TrimSpace(fcrepoEnv.User)) > 0)
}

// Password should not be null and non-empty
func Test_Password(t *testing.T) {
	assert.NotNil(t, fcrepoEnv.Password)
	assert.True(t, len(strings.TrimSpace(fcrepoEnv.Password)) > 0)
}

// Data dir should not be null and non-empty
func Test_DataDir(t *testing.T) {
	assert.NotNil(t, fcrepoEnv.DataDir)
	assert.True(t, len(strings.TrimSpace(fcrepoEnv.DataDir)) > 0)
}

// SpAuthHeader should not be null and non-empty
func Test_SpAuthHeader(t *testing.T) {
	assert.NotNil(t, fcrepoEnv.SpAuthHeader)
	assert.True(t, len(strings.TrimSpace(fcrepoEnv.SpAuthHeader)) > 0)
}

// SpAuthRoles should not be null and non-empty
func Test_SpAuthRoles(t *testing.T) {
	assert.NotNil(t, fcrepoEnv.SpAuthRoles)
	assert.True(t, len(strings.TrimSpace(fcrepoEnv.SpAuthRoles)) > 0)
}

// AuthRealm should not be null and non-empty
func Test_AuthRealm(t *testing.T) {
	assert.NotNil(t, fcrepoEnv.AuthRealm)
	assert.True(t, len(strings.TrimSpace(fcrepoEnv.AuthRealm)) > 0)
}

// ModeConfig should not be null and non-empty
func Test_ModeConfig(t *testing.T) {
	assert.NotNil(t, fcrepoEnv.ModeConfig)
	assert.True(t, len(strings.TrimSpace(fcrepoEnv.ModeConfig)) > 0)
}

// PublicBaseUri should not be null and non-empty
func Test_PublicBaseUri(t *testing.T) {
	assert.NotNil(t, fcrepoEnv.PublicBaseUri)
	assert.True(t, len(strings.TrimSpace(fcrepoEnv.PublicBaseUri)) > 0)
}