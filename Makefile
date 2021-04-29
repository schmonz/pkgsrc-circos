# $NetBSD: Makefile,v 1.16 2022/06/28 11:33:59 wiz Exp $
#

DISTNAME=	circos-0.69-9
PKGNAME=	circos-0.69.9
CATEGORIES=	graphics
MASTER_SITES=	http://circos.ca/distribution/
EXTRACT_SUFX=	.tgz

MAINTAINER=	schmonz@NetBSD.org
HOMEPAGE=	http://circos.ca/
COMMENT=	Concise, explanatory, unique and print-ready data visualization
LICENSE=	gnu-gpl-v3

USE_LANGUAGES=	# none
USE_TOOLS+=	pax perl bash:run
NO_BUILD=	yes

DEPENDS+=	p5-Clone-[0-9]*:../../devel/p5-Clone
DEPENDS+=	p5-Config-General>=2.54:../../devel/p5-Config-General
DEPENDS+=	p5-Font-TTF-[0-9]*:../../fonts/p5-Font-TTF
DEPENDS+=	p5-GD-[0-9]*:../../graphics/p5-GD
DEPENDS+=	p5-Math-Bezier-[0-9]*:../../math/p5-Math-Bezier
DEPENDS+=	p5-Math-Round-[0-9]*:../../math/p5-Math-Round
DEPENDS+=	p5-Math-VecStat-[0-9]*:../../math/p5-Math-VecStat
DEPENDS+=	p5-Params-Validate-[0-9]*:../../devel/p5-Params-Validate
DEPENDS+=	p5-Readonly-[0-9]*:../../devel/p5-Readonly
DEPENDS+=	p5-Regexp-Common-[0-9]*:../../textproc/p5-Regexp-Common
DEPENDS+=	p5-SVG-[0-9]*:../../graphics/p5-SVG
DEPENDS+=	p5-Set-IntSpan>=1.16:../../devel/p5-Set-IntSpan
DEPENDS+=	p5-Statistics-Basic-[0-9]*:../../math/p5-Statistics-Basic
DEPENDS+=	p5-Text-Format-[0-9]*:../../textproc/p5-Text-Format

PKG_SYSCONFSUBDIR=	${PKGBASE}
INSTALLATION_DIRS+=	bin share/${PKGBASE} share/examples/${PKGBASE}
INSTALLATION_DIRS+=	share/doc/${PKGBASE}
INSTALLATION_DIRS+=	${PERL5_SUB_INSTALLVENDORLIB}/Circos
EGDIR=			share/examples/${PKGBASE}

# XXX do I need to `chdir` somewhere early in `circos`?

# XXX is this all that's needed
# what about other examples outside etc
CONF_FILES+=		${EGDIR}/colors.conf ${PKG_SYSCONFDIR}/colors.conf
CONF_FILES+=		${EGDIR}/fonts.conf ${PKG_SYSCONFDIR}/fonts.conf

SUBST_CLASSES+=		paths
SUBST_STAGE.paths=	do-configure
SUBST_FILES.paths=	bin/circos lib/Circos/Error.pm
SUBST_FILES.paths+=	etc/colors_fonts_patterns.conf
SUBST_FILES.paths+=	etc/brewer.conf etc/gddiag.conf
SUBST_SED.paths=	-e 's|<<include etc/\(.*\)>>|<<include ${PKG_SYSCONFDIR}/\1>>|g'

REPLACE_PERL+=	bin/gddiag bin/circos etc/makehuesteps

REPLACE_BASH+=	data/karyotype/parse.karyotype data/karyotype/assembly/parse.assembly

pre-configure:
	cd ${WRKSRC} && rm -f bin/*.orig

# XXX does the example still run?
do-install:
	cd ${WRKSRC} &&							\
	for f in CHANGES CITATION README README.tutorials TODO; do		\
		${INSTALL_DATA} $${f} ${DESTDIR}${PREFIX}/share/doc/${PKGBASE};	\
	done;								\
	for f in bin/circos bin/gddiag; do				\
		${INSTALL_SCRIPT} $${f} ${DESTDIR}${PREFIX}/bin;	\
	done;								\
	for f in lib/Circos.pm; do				\
		${INSTALL_DATA} $${f} ${DESTDIR}${PREFIX}/${PERL5_SUB_INSTALLVENDORLIB};	\
	done;								\
	pax -rw -pp data error fonts tiles ${DESTDIR}${PREFIX}/share/${PKGBASE};	\
	cd etc && pax -rw -pp . ${DESTDIR}${PREFIX}/${EGDIR};		\
	cd ../lib/Circos && pax -rw -pp . ${DESTDIR}${PREFIX}/${PERL5_SUB_INSTALLVENDORLIB}/Circos

.include "../../mk/bsd.pkg.mk"
