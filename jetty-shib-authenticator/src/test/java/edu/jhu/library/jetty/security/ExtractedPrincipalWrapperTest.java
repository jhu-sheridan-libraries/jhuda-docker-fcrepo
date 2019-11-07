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

import org.junit.Before;
import org.junit.Test;

import javax.servlet.http.HttpServletRequest;
import java.util.NoSuchElementException;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

public class ExtractedPrincipalWrapperTest {

    private static final String PRINCIPAL_HEADER_NAME = "MOO";

    private HttpServletRequest req;

    private ExtractedPrincipalWrapper underTest;

    @Before
    public void setUp() throws Exception {
        req = mock(HttpServletRequest.class);
        underTest = new ExtractedPrincipalWrapper(req, PRINCIPAL_HEADER_NAME);
    }

    /**
     * The value of the header should be returned as expected
     */
    @Test
    public void extractHeaderSuccess() {
        when(req.getHeader(PRINCIPAL_HEADER_NAME)).thenReturn("Cow");
        assertEquals("Cow", ExtractedPrincipalWrapper.extract(req, PRINCIPAL_HEADER_NAME).get());
    }

    /**
     * The value of the header should be trimmed
     */
    @Test
    public void extractHeaderTrimmed() {
        when(req.getHeader(PRINCIPAL_HEADER_NAME)).thenReturn(" Cow ");
        assertEquals("Cow", ExtractedPrincipalWrapper.extract(req, PRINCIPAL_HEADER_NAME).get());
    }

    /**
     * When the specified header isn't found null should be returned
     */
    @Test(expected = NoSuchElementException.class)
    public void extractNonExistentHeader() {
        when(req.getHeader(PRINCIPAL_HEADER_NAME)).thenReturn(null);
        assertFalse(ExtractedPrincipalWrapper.extract(req, PRINCIPAL_HEADER_NAME).isPresent());
        ExtractedPrincipalWrapper.extract(req, PRINCIPAL_HEADER_NAME).get();
    }

    /**
     * the empty string is considered null
     */
    @Test(expected = NoSuchElementException.class)
    public void extractHeaderEmptyStringValue() {
        when(req.getHeader(PRINCIPAL_HEADER_NAME)).thenReturn(" ");
        assertFalse(ExtractedPrincipalWrapper.extract(req, PRINCIPAL_HEADER_NAME).isPresent());
        ExtractedPrincipalWrapper.extract(req, PRINCIPAL_HEADER_NAME).get();
    }

    /**
     * the zero-length string is considered null
     */
    @Test(expected = NoSuchElementException.class)
    public void extractHeaderZeroLengthStringValue() {
        when(req.getHeader(PRINCIPAL_HEADER_NAME)).thenReturn("");
        assertFalse(ExtractedPrincipalWrapper.extract(req, PRINCIPAL_HEADER_NAME).isPresent());
        ExtractedPrincipalWrapper.extract(req, PRINCIPAL_HEADER_NAME).get();
    }

    /**
     * the remote user should be returned from the specified principal header
     */
    @Test
    public void getRemoteUserSuccess() {
        when(req.getHeader(PRINCIPAL_HEADER_NAME)).thenReturn("Cow");
        assertEquals("Cow", underTest.getRemoteUser());
    }

    /**
     * the principal should be returned from the specified principal header
     */
    @Test
    public void getPrincipalSuccess() {
        when(req.getHeader(PRINCIPAL_HEADER_NAME)).thenReturn("Cow");
        assertEquals("Cow", underTest.getUserPrincipal().getName());
    }

    /**
     * the remote user should be null if the principal header is missing
     */
    @Test
    public void getRemoteUserNonExistentHeader() {
        when(req.getHeader(PRINCIPAL_HEADER_NAME)).thenReturn(null);
        assertNull(underTest.getRemoteUser());
    }

    /**
     * the principal should be null if the principal header is missing
     */
    @Test
    public void getPrincipalNonExistentHeader() {
        when(req.getHeader(PRINCIPAL_HEADER_NAME)).thenReturn(null);
        assertNull(underTest.getUserPrincipal());
    }

    /**
     * the remote user should be null if the principal header is an empty string
     */
    @Test
    public void getRemoteUserEmptyHeader() {
        when(req.getHeader(PRINCIPAL_HEADER_NAME)).thenReturn(" ");
        assertNull(underTest.getRemoteUser());
    }

    /**
     * the principal should be null if the principal header is an empty string
     */
    @Test
    public void getPrincipalEmptyHeader() {
        when(req.getHeader(PRINCIPAL_HEADER_NAME)).thenReturn(" ");
        assertNull(underTest.getUserPrincipal());
    }
}
