/*
 *
 *  * Copyright 2019 Johns Hopkins University
 *  *
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

package edu.jhu.library.jetty.security;

import org.eclipse.jetty.security.Authenticator;
import org.eclipse.jetty.security.ServerAuthException;
import org.eclipse.jetty.security.authentication.BasicAuthenticator;
import org.eclipse.jetty.security.authentication.DeferredAuthentication;
import org.eclipse.jetty.server.Authentication;
import org.eclipse.jetty.util.log.Log;
import org.eclipse.jetty.util.log.Logger;

import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Arrays;
import java.util.stream.Collectors;

/**
 * Validates the incoming request by extracting the Principal and remote user from request headers.
 * <p>
 * The header used to extract the Principal is configured by {@link #setHeaderName(String)}.  Roles can optionally be
 * supplied for the Principal with {@link #setDefaultRoles(String)}.
 * </p>
 * <p>
 * If the incoming request does not contain a Principal, basic auth will be used to authenticate the request.
 * </p>
 */
public class ShibbolethHeaderAuthenticator implements Authenticator {

    private static final Logger LOG = Log.getLogger(ShibbolethHeaderAuthenticator.class);

    private AuthConfiguration configuration;

    private String authMethod;

    /**
     * The header that contains the remote user and Principal name.
     */
    private String headerName;

    /**
     * A comma-delimited string of roles that the Principal will belong to.  These are effectively fixed for all
     * Principals (every authenticated user will have the same set of roles supplied by this field).
     */
    private String defaultRoles;

    @Override
    public void setConfiguration(AuthConfiguration configuration) {
        this.configuration = configuration;
    }

    @Override
    public String getAuthMethod() {
        return authMethod;
    }

    @Override
    public void prepareRequest(ServletRequest request) {
        // no-op
    }

    /**
     * Returns a {@link Authentication.Wrapped} object containing a wrapped request.  The wrapped request will answer
     * {@link HttpServletRequest#getRemoteUser() getRemoteUser} and {@link HttpServletRequest#getUserPrincipal()} by
     * matching the HTTP header supplied by {@link #setHeaderName(String)} and returning its value.  User roles
     * supplied by {@link #setDefaultRoles(String)} will be consulted by {@link HttpServletRequest#isUserInRole(String)}.
     * <p>
     * If the wrapped request does encapsulate a Principal, a {@link DeferredAuthentication} is returned which utilizes
     * BASIC auth.
     * </p>
     *
     * @param request the incoming request which will be wrapped by this method
     * @param response the outgoing response
     * @param mandatory whether or not authentication is required (this parameter is ignored)
     * @return a {@link Authentication.Wrapped} object which extracts the remote user and principals from HTTP headers
     * @throws ServerAuthException if bad things happen
     */
    @Override
    public Authentication validateRequest(ServletRequest request, ServletResponse response, boolean mandatory)
            throws ServerAuthException {
        LOG.debug("Validating request ...");

        ExtractedPrincipalWrapper extractedPrincipalWrapper =
                new ExtractedPrincipalWrapper((HttpServletRequest) request,
                        headerName,
                        Arrays.stream(defaultRoles.split(",")).collect(Collectors.toSet()));

        if (extractedPrincipalWrapper.principalFound()) {
            LOG.debug("{} extracted Principal: {}", ExtractedPrincipalWrapper.class.getSimpleName(), extractedPrincipalWrapper.getRemoteUser());

            return new Authentication.Wrapped() {
                @Override
                public HttpServletRequest getHttpServletRequest() {
                    return extractedPrincipalWrapper;
                }

                @Override
                public HttpServletResponse getHttpServletResponse() {
                    return (HttpServletResponse) response;
                }
            };
        }

        LOG.debug("{} returning {}", ExtractedPrincipalWrapper.class.getSimpleName(), DeferredAuthentication.class.getSimpleName());
        return new DeferredAuthentication(new BasicAuthenticator());
    }

    @Override
    public boolean secureResponse(ServletRequest request, ServletResponse response, boolean mandatory, Authentication.User validatedUser) throws ServerAuthException {
        return false;
    }

    public void setAuthMethod(String authMethod) {
        this.authMethod = authMethod;
    }

    public String getHeaderName() {
        return headerName;
    }

    public void setHeaderName(String headerName) {
        this.headerName = headerName;
    }

    public String getDefaultRoles() {
        return defaultRoles;
    }

    public void setDefaultRoles(String defaultRoles) {
        this.defaultRoles = defaultRoles;
    }
}
