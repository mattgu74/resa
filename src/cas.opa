/**
 * An opa CAS client
 *
 * See http://www.jasig.org/cas/protocol
 *
 * @auhtor Matthieu Guffroy
 *
 * See https://github.com/mattgu74/opaCas
 */

/*
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
 * Warning This module is in construction only a few part of the protocol is
 * handled...
 */

package mattgu74.cas

import stdlib.web.client

type Cas.config = 
  {
    url : string ;  // Url of the cas service
    service : string // Url of the service
  }

type Cas.ticket = { ticket : string } / {no}

type Cas.status = { logged : string } / { unlogged }
type Cas.info = UserContext.t(Cas.status)

Cas(conf : Cas.config) = {{

  @private state = UserContext.make({ unlogged } : Cas.status)

  login_url() =
    String.concat("", [conf.url, "login?service=", "http://{Option.default("localhost", Option.default(some("localhost"), HttpRequest.get_host()))}", conf.service, "/CAS/ticket"])

  login_url_to(url : string) =
    String.concat("", [conf.url, "login?service=", "http://{Option.default("localhost", Option.default(some("localhost"), HttpRequest.get_host()))}", conf.service, "/CAS/ticket_url/", url])


  @private logout_url() =
    String.concat("", [conf.url, "logout?url=", "http://{Option.default("localhost", Option.default(some("localhost"), HttpRequest.get_host()))}", conf.service])

  @private xml_match(xml) = 
    match xml with
      | {namespace = name; tag = tag; args = args;
        content = cont; specific_attributes = _ } -> {name = name ; tag = tag ; args = args ; cont = cont} 
      | _ -> { name = "" ; tag = "" ; args = [] ; cont = []} 

  @private status_from_xml(xml) =
   match xml_match(xml) with
    | {name = "cas"; tag="serviceResponse" ; args=_ ; cont=c1} -> 
      funa(x1) = 
        match xml_match(x1) with 
          | {name = "cas"; tag="authenticationSuccess" ; ... } -> true
          | _ -> false
        end
      next1 = List.find(funa,c1)
      match next1 with
        | {some = s1} -> 
          funb(x2) = 
            match xml_match(x2) with 
              | {name = "cas"; tag="user" ; ... } -> true
              | _ -> false
             end
            w = xml_match(s1)
            next2 = List.find(funb,w.cont)
            match next2 with
              | {some = s2} -> w = xml_match(s2)
                               match List.head(w.cont) with
                                | {text = t} -> {logged = String.replace(" ", "", t)}
                                | _ -> {unlogged}
                               end
              | {none} -> {unlogged}
             end
        | _ -> { unlogged }
       end
    | _ -> { unlogged }

  @private server_validate(uri) =
    match WebClient.Result.as_xml(WebClient.Get.try_get(uri)) with
      | {failure = _} -> jlog("[CAS failure 1]")
      | {~success}    -> match WebClient.Result.get_class(success) with
        | {success} -> do UserContext.change((_ -> status_from_xml(success.content) ), state)
                       void
        | _         -> jlog("[CAS failure 2]")
    end

  get_status() =
    UserContext.execute(( a -> a), state)

  get_login() = 
    match get_status() with
     | {logged=a} -> a
     | {unlogged} -> "anonymous"

  is_logged() =
    match get_status() with
     | {logged=_} -> true
     | {unlogged} -> false

  validate(t) =
   the_uri = Uri.of_string( String.concat( "" , [conf.url, "serviceValidate?service=", "http://{Option.default("localhost", Option.default(some("localhost"), HttpRequest.get_host()))}", conf.service, "/CAS/ticket&ticket=", t]))
   match the_uri with
     | {some = uri} -> server_validate(uri)
     | {none} -> jlog("[CAS ECHEC URI OF STRING CONCAT]")

  validate_url(t,url) =
   the_uri = Uri.of_string( String.concat( "" , [conf.url, "serviceValidate?service=", "http://{Option.default("localhost", Option.default(some("localhost"), HttpRequest.get_host()))}", conf.service, "/CAS/ticket_url/",url,"&ticket=", t]))
   match the_uri with
     | {some = uri} -> server_validate(uri)
     | {none} -> jlog("[CAS ECHEC URI OF STRING CONCAT]") 

  start() =
    body = <>CAS module</>
    Resource.html("CAS module", body)

  login() =
    Resource.redirection_page("",<></>,{success},0,login_url())

  login_to(url) =
    Resource.redirection_page("",<></>,{success},0,login_url_to(url))

  logout() : resource =
    do UserContext.change(( _ -> { unlogged }), state) 
    Resource.redirection_page("",<></>,{success},0,logout_url())

  logout_void() : void =
    do UserContext.change(( _ -> { unlogged }), state) 
    Client.goto(logout_url())

  ticket(n) = 
    myParser =
     parser
     | "?ticket=" n=(.*) ->
       { ticket = Text.to_string(n) }
     | .* -> 
       {no}
    ticket = Parser.parse(myParser, n)
    do match ticket with
       | { ticket = t } -> validate(t)
       | {no} -> void
    Resource.redirection_page("",<></>,{success},0,conf.service)

  ticket_url(n,url) = 
    myParser =
     parser
     | "ticket=" n=(.*) ->
       { ticket = Text.to_string(n) }
     | .* -> 
       {no}
    ticket = Parser.parse(myParser, n)
    do match ticket with
       | { ticket = t } -> validate_url(t,url)
       | {no} -> jlog("[CAS Ticket is not a ticket]")
    Resource.redirection_page("",<></>,{success},0,url) 

  resource : Parser.general_parser(resource) =
    parser
    | "/CAS/login" ->
      login()
    | "/CAS/logout" ->
      logout()
    | "/CAS/ticket_url/" url=((![?] .)*) "?" n=(.*) -> ticket_url(Text.to_string(n), Text.to_string(url))
    | "/CAS/ticket" n=(.*) -> ticket(Text.to_string(n))
	| "/CAS/info" -> Resource.html("CAS INFO", match get_status() with
												| {logged=a} -> <>{a} is logged</>
												| {unlogged} -> <>No one is logged</>
												)
    | "/CAS" .* ->
      start()

}}
