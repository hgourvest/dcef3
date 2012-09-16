(*
 *                       Delphi Chromium Embedded
 *
 * Usage allowed under the restrictions of the Lesser GNU General Public License
 * or alternatively the restrictions of the Mozilla Public License 1.1
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * Unit owner : Henri Gourvest <hgourvest@gmail.com>
 * Web site   : http://www.progdigy.com
 * Repository : http://code.google.com/p/delphichromiumembedded/
 * Group      : http://groups.google.com/group/delphichromiumembedded
 *)

 {.$define CEF_STRING_TYPE_UTF8}
{$define CEF_STRING_TYPE_UTF16}
{.$define CEF_STRING_TYPE_WIDE}

{.$DEFINE CEF_MULTI_THREADED_MESSAGE_LOOP}

{$IFDEF FPC}
  // force multithreading message loop on FPC, still not work
  {$DEFINE CEF_MULTI_THREADED_MESSAGE_LOOP}
  {$DEFINE SUPPORTS_INLINE}
{$ENDIF}

{$IFDEF VER130}
  {$DEFINE DELPHI5_UP}
{$ENDIF}

{$IFDEF VER140}
  {$DEFINE DELPHI5_UP}
  {$DEFINE DELPHI6_UP}
{$ENDIF}

{$IFDEF VER150}
  {$DEFINE DELPHI5_UP}
  {$DEFINE DELPHI6_UP}
  {$DEFINE DELPHI7_UP}
{$ENDIF}

{$IFDEF VER160}
  // DELPHI 8 for Dotnet
  {$DEFINE DELPHI5_UP}
  {$DEFINE DELPHI6_UP}
  {$DEFINE DELPHI7_UP}
  {$DEFINE DELPHI8_UP}
{$ENDIF}

// Delphi 2005
{$IFDEF VER170}
  {$DEFINE SUPPORTS_INLINE}
  {$DEFINE DELPHI5_UP}
  {$DEFINE DELPHI6_UP}
  {$DEFINE DELPHI7_UP}
  {$DEFINE DELPHI8_UP}
  {$DEFINE DELPHI9_UP}
{$ENDIF}

{$IFDEF VER180}
  // Delphi 2007
  {$IFDEF VER185}
    {$DEFINE SUPPORTS_INLINE}
    {$DEFINE DELPHI5_UP}
    {$DEFINE DELPHI6_UP}
    {$DEFINE DELPHI7_UP}
    {$DEFINE DELPHI8_UP}
    {$DEFINE DELPHI9_UP}
    {$DEFINE DELPHI10_UP}
    {$DEFINE DELPHI11_UP}
  // Delphi 2006
  {$ELSE}
    {$DEFINE SUPPORTS_INLINE}
    {$DEFINE DELPHI5_UP}
    {$DEFINE DELPHI6_UP}
    {$DEFINE DELPHI7_UP}
    {$DEFINE DELPHI8_UP}
    {$DEFINE DELPHI9_UP}
    {$DEFINE DELPHI10_UP}
  {$ENDIF}
{$ENDIF}

// Delphi 2009
{$IFDEF VER200}
  {$DEFINE SUPPORTS_INLINE}
  {$DEFINE DELPHI5_UP}
  {$DEFINE DELPHI6_UP}
  {$DEFINE DELPHI7_UP}
  {$DEFINE DELPHI8_UP}
  {$DEFINE DELPHI9_UP}
  {$DEFINE DELPHI10_UP}
  {$DEFINE DELPHI11_UP}
  {$DEFINE DELPHI12_UP}
{$ENDIF}

//Delphi 2010
{$IFDEF VER210}
  {$DEFINE SUPPORTS_INLINE}
  {$DEFINE DELPHI5_UP}
  {$DEFINE DELPHI6_UP}
  {$DEFINE DELPHI7_UP}
  {$DEFINE DELPHI8_UP}
  {$DEFINE DELPHI9_UP}
  {$DEFINE DELPHI10_UP}
  {$DEFINE DELPHI11_UP}
  {$DEFINE DELPHI12_UP}
  {$DEFINE DELPHI14_UP}
{$ENDIF}

// Delphi XE
{$IFDEF VER220}
  {$DEFINE SUPPORTS_INLINE}
  {$DEFINE DELPHI5_UP}
  {$DEFINE DELPHI6_UP}
  {$DEFINE DELPHI7_UP}
  {$DEFINE DELPHI8_UP}
  {$DEFINE DELPHI9_UP}
  {$DEFINE DELPHI10_UP}
  {$DEFINE DELPHI11_UP}
  {$DEFINE DELPHI12_UP}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
{$ENDIF}

{$IFDEF VER230}
  {$DEFINE SUPPORTS_INLINE}
  {$DEFINE DELPHI5_UP}
  {$DEFINE DELPHI6_UP}
  {$DEFINE DELPHI7_UP}
  {$DEFINE DELPHI8_UP}
  {$DEFINE DELPHI9_UP}
  {$DEFINE DELPHI10_UP}
  {$DEFINE DELPHI11_UP}
  {$DEFINE DELPHI12_UP}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
{$ENDIF}

{$IFDEF VER240}
  {$DEFINE SUPPORTS_INLINE}
  {$DEFINE DELPHI5_UP}
  {$DEFINE DELPHI6_UP}
  {$DEFINE DELPHI7_UP}
  {$DEFINE DELPHI8_UP}
  {$DEFINE DELPHI9_UP}
  {$DEFINE DELPHI10_UP}
  {$DEFINE DELPHI11_UP}
  {$DEFINE DELPHI12_UP}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
{$ENDIF}