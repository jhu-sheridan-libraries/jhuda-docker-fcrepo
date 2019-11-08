package env

import (
	"github.com/stretchr/testify/assert"
	"net/url"
	"strconv"
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
