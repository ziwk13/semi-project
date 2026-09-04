package org.puppit.controller;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

public class LoggerInterceptor implements HandlerInterceptor {
  
  @Override
  public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
    String ctx = request.getContextPath();
    String uri = request.getRequestURI();
    String path = uri.substring(ctx.length());
    
    boolean isPublic = path.equals("/user/login")
                    || path.equals("/user/signup")
                    || path.equals("/user/find")
                    || path.equals("/user/check")
                    || path.equals("/user/reset-password")
                    || path.equals("/auth");
    
    if(isPublic) return true;
    // 세션에서 사용자 정보 조회
    HttpSession session = request.getSession(false);
    @SuppressWarnings("unchecked")
    Map<String, Object> sessionMap = (session == null) ? null : (Map<String, Object>) session.getAttribute("sessionMap");
    boolean authenticated = (sessionMap != null && sessionMap.get("userId") != null);
    
    if(authenticated) return true;
    
    if(!path.startsWith("/user/login")) {
      String q = request.getQueryString();
      String returnTo = (q == null) ? uri : uri + "?" + q;
      request.getSession(true).setAttribute("redirectAfterLogin", returnTo);
    }
    
    response.sendRedirect(request.getContextPath() + "/user/login");
    return false;
  }
  
  @Override
  public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler,
      ModelAndView modelAndView) throws Exception {
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    response.setHeader("Pragma", "no-cache");
  }
}
