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

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;
import java.security.Principal;
import java.util.Collections;
import java.util.Optional;
import java.util.Set;

/**
 * Obtains the {@link HttpServletRequest#getRemoteUser() remote user} and {@link HttpServletRequest#getUserPrincipal()
 * user principal} from a specified HTTP request header.
 */
public class ExtractedPrincipalWrapper extends HttpServletRequestWrapper {

    /**
     * Name of the HTTP header that contains the authenticated user
     */
    private String userHeader;

    /**
     * The HTTP servlet request being wrapped by this ExtractedPrincipalWrapper
     */
    private HttpServletRequest underlyingRequest;

    /**
     * The roles the authenticated user has, e.g. 'fedoraUser'
     */
    private Set<String> roles;

    /**
     * Wraps the supplied request, extracting the remote user and principal from the supplied HTTP request header.
     *
     * @param request the request being wrapped
     * @param userHeader the name of the header containing the authenticated user
     */
    public ExtractedPrincipalWrapper(HttpServletRequest request, String userHeader) {
        this(request, userHeader, Collections.emptySet());
    }

    /**
     * Wraps the supplied request, extracting the remote user and principal from the supplied HTTP request header.
     * {@link HttpServletRequest#isUserInRole(String)} will return {@code true} for any role specified in {@code roles}.
     *
     * @param request the request being wrapped
     * @param userHeader the name of the header containing the authenticated user
     * @param roles the roles associated with the principal extracted from the underlying request
     */
    public ExtractedPrincipalWrapper(HttpServletRequest request, String userHeader, Set<String> roles) {
        super(request);
        this.underlyingRequest = request;
        this.userHeader = userHeader;
        this.roles = roles;
    }

    /**
     * Returns {@code true} if this wrapper is able to obtain a Principal from the underlying request.
     *
     * @return true if the underlying request contains a Principal
     */
    boolean principalFound() {
        return getUserPrincipal() != null;
    }

    @Override
    public Principal getUserPrincipal() {
        return extract(underlyingRequest, userHeader)
                .map(user -> (Principal) () -> user)
                .orElse(() -> null);
    }

    @Override
    public String getRemoteUser() {
        return extract(underlyingRequest, userHeader)
                .orElse(null);
    }

    @Override
    public boolean isUserInRole(String role) {
        return roles.contains(role);
    }

    /**
     * Examines the request for the specified HTTP request header and trims the value.  Zero-length strings are
     * considered the same as if the header was never set in the first place.
     *
     * @param underlyingRequest the underlying HTTP request that may carry a value for the specified header
     * @param userHeader the name of the header containing the authenticated user
     * @return the trimmed value of the header, or {@code null} if the header is missing or has a zero-length string as
     *         its value
     */
    private static Optional<String> extract(HttpServletRequest underlyingRequest, String userHeader) {
        return Optional.ofNullable(underlyingRequest.getHeader(userHeader))
                .map(String::trim)
                .map(value -> "".equals(value) ? null : value);
    }
}
