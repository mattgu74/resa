package mattgu74.cas

import stdlib.web.client

type Cas.config = {string url, string service}

type Cas.ticket = or {string ticket}
                  or {no}

type Cas.status = or {string logged}
                  or {unlogged}

type Cas.info = UserContext.t(Cas.status)

function Cas(Cas.config conf) {
    module  {
    private state = UserContext.make((Cas.status) {unlogged})
    function login_url() {
        String.concat("",
          [conf.url, "login?service=",
            "http://{Option.`default`("localhost",
                       Option.`default`(some("localhost"),
                         HttpRequest.get_host()))}",
            conf.service, "/CAS/ticket"])
    }
    function login_url_to(string url) {
        String.concat("",
          [conf.url, "login?service=",
            "http://{Option.`default`("localhost",
                       Option.`default`(some("localhost"),
                         HttpRequest.get_host()))}",
            conf.service, "/CAS/ticket_url/", url])
    }
    private function logout_url() {
        String.concat("",
          [conf.url, "logout?url=",
            "http://{Option.`default`("localhost",
                       Option.`default`(some("localhost"),
                         HttpRequest.get_host()))}",
            conf.service])
    }
    private function xml_match(xml) {
        match (xml) {
        case { namespace :
               name,
               ~tag,
               ~args,
               content :
               cont,
               specific_attributes :
               _ 
               }:
          ~{name, tag, args, cont}
        default: {name : "", tag : "", args : [], cont : []}
        }
    }
    private function status_from_xml(xml) {
        match (xml_match(xml)) {
        case { name : "cas", tag : "serviceResponse", args : _, cont : c1 }:
          function funa(x1) {
              match (xml_match(x1)) {
              case { name : "cas", tag : "authenticationSuccess", ... }: true
              default: false
              }
          }
          next1 = List.find(funa, c1);
          match (next1) {
          case { some : s1 }:
            function funb(x2) {
                match (xml_match(x2)) {
                case { name : "cas", tag : "user", ... }: true
                default: false
                }
            }
            w = xml_match(s1);
            next2 = List.find(funb, w.cont);
            match (next2) {
            case { some : s2 }:
              w = xml_match(s2);
              match (List.head(w.cont)) {
              case { text : t }: {logged : String.replace(" ", "", t)}
              default: {unlogged}
              }
            case { none }: {unlogged}
            }
          default: {unlogged}
          }
        default: {unlogged}
        }
    }
    private function server_validate(uri) {
        match (WebClient.Result.as_xml(WebClient.Get.try_get(uri))) {
        case { failure : _ }: jlog("[CAS failure 1]")
        case ~{ success }:
          match (WebClient.Result.get_class(success)) {
          case { success }:
            UserContext.change((function(_) {
                                status_from_xml(success.content)
              }), state);
            void
          default: jlog("[CAS failure 2]")
          }
        }
    }
    function get_status() {
        UserContext.execute((function(a) {
                             a
          }), state)
    }
    function get_login() {
        match (get_status()) {
        case { logged : a }: a
        case { unlogged }: "anonymous"
        }
    }
    function is_logged() {
        match (get_status()) {
        case { logged : _ }: true
        case { unlogged }: false
        }
    }
    function validate(t) {
        the_uri =
            Uri.of_string(String.concat("",
                            [conf.url, "serviceValidate?service=",
                              "http://{Option.`default`("localhost",
                                         Option.`default`(some("localhost"),
                                           HttpRequest.get_host()))}",
                              conf.service, "/CAS/ticket&ticket=", t]));
        match (the_uri) {
        case { some : uri }: server_validate(uri)
        case { none }: jlog("[CAS ECHEC URI OF STRING CONCAT]")
        }
    }
    function validate_url(t, url) {
        the_uri =
            Uri.of_string(String.concat("",
                            [conf.url, "serviceValidate?service=",
                              "http://{Option.`default`("localhost",
                                         Option.`default`(some("localhost"),
                                           HttpRequest.get_host()))}",
                              conf.service, "/CAS/ticket_url/", url,
                              "&ticket=", t]));
        match (the_uri) {
        case { some : uri }: server_validate(uri)
        case { none }: jlog("[CAS ECHEC URI OF STRING CONCAT]")
        }
    }
    function start() {
        xhtml body = <>CAS module</>;
        Resource.html("CAS module", body)
    }
    function login() {
        Resource.redirection_page("", <></>, {success}, 0, login_url())
    }
    function login_to(url) {
        Resource.redirection_page("", <></>, {success}, 0, login_url_to(url))
    }
    function resource logout() {
        UserContext.change((function(_) {
                            {unlogged}
          }), state);
        Resource.redirection_page("", <></>, {success}, 0, logout_url())
    }
    function void logout_void() {
        UserContext.change((function(_) {
                            {unlogged}
          }), state);
        Client.goto(logout_url())
    }
    function ticket(n) {
         myParser = {
            parser{
            "?ticket="
            n = (.*) :
            {ticket : Text.to_string(n)}
            case .* : {no}}
            }
            ticket = Parser.parse(myParser, n);
            match (ticket) {
                case { ticket : t }: validate(t)
                case { no }: void
                }
                ;
            Resource.redirection_page("", <></>, {success}, 0, conf.service)
        }
        function ticket_url(n, url) {
             myParser = {
                parser{
                "ticket="
                n = (.*) :
                {ticket : Text.to_string(n)}
                case .* : {no}}
                }
                ticket = Parser.parse(myParser, n);
                match (ticket) {
                    case { ticket : t }: validate_url(t, url)
                    case { no }: jlog("[CAS Ticket is not a ticket]")
                    }
                    ;
                Resource.redirection_page("", <></>, {success}, 0, url)
            }
             Parser.general_parser(resource) resource = {
                parser{
                "/CAS/login" :
                login() case "/CAS/logout" : logout()
                case "/CAS/ticket_url/" url = ((![?] .)*) "?" n = (.*) :
                  ticket_url(Text.to_string(n), Text.to_string(url))
                case "/CAS/ticket" n = (.*) : ticket(Text.to_string(n))
                case "/CAS/info" :
                  Resource.html("CAS INFO",
                    match (get_status()) {
                    case { logged : a }: <>{a} is logged</>
                    case { unlogged }: <>No one is logged</>
                    })
                case "/CAS" .* : start()}
                }
            }
        }