#!/usr/bin/python
"""Set user's gmail signature."""

import optparse
import subprocess
import textwrap


DOMAIN = 'example.com'
WEBSITE = 'www.example.com'
IMAGE = 'http://www.example.com/sig.png'


def main():
    """Set user's Gmail Sig."""

    parser = optparse.OptionParser()
    parser.add_option('--username', '-u', dest='username',
                      help="username")
    parser.add_option('--firstname', '-f', dest='firstname',
                      help="firstname")
    parser.add_option('--lastname', '-l', dest='lastname',
                      help="lastname")

    opts, args = parser.parse_args()

    if not (opts.username and opts.firstname and opts.lastname):
        parser.error('username, firstname, and lastname all required.')
    if args:
        parser.error('Extraneous command line options found.')

    content = textwrap.dedent("""\
            <div dir="ltr"><div>%(firstname)s %(lastname)s &lt;<a
             href="mailto:%(username)s@%(domain)s"
             target="_blank">%(username)s@%(domain)s</a>&gt;</div
            ><div><br></div><div><
            a href="%(website)s
             target="_blank"><img
             src="%(image)s"></a><br></div></div>
            """ % {'domain': DOMAIN,
                   'firstname': opts.firstname,
                   'image': IMAGE,
                   'lastname': opts.lastname,
                   'username': opts.username,
                   'website': WEBSITE,
                   }).replace('\n', '')

    subprocess.call(['gam',
                     'user',
                     opts.username,
                     'signature',
                     content])


if __name__ == '__main__':
    main()
