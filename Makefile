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
DEPENDS+=	p5-Config-General-[0-9]*:../../devel/p5-Config-General
DEPENDS+=	p5-Font-TTF-[0-9]*:../../fonts/p5-Font-TTF
DEPENDS+=	p5-GD-[0-9]*:../../graphics/p5-GD
DEPENDS+=	p5-List-MoreUtils-[0-9]*:../../devel/p5-List-MoreUtils
DEPENDS+=	p5-Math-Bezier-[0-9]*:../../math/p5-Math-Bezier
DEPENDS+=	p5-Math-Round-[0-9]*:../../math/p5-Math-Round
DEPENDS+=	p5-Math-VecStat-[0-9]*:../../math/p5-Math-VecStat
DEPENDS+=	p5-Number-Format-[0-9]*:../../textproc/p5-Number-Format
DEPENDS+=	p5-Params-Validate-[0-9]*:../../devel/p5-Params-Validate
DEPENDS+=	p5-Readonly-[0-9]*:../../devel/p5-Readonly
DEPENDS+=	p5-Regexp-Common-[0-9]*:../../textproc/p5-Regexp-Common
DEPENDS+=	p5-SVG-[0-9]*:../../graphics/p5-SVG
DEPENDS+=	p5-Scalar-List-Utils-[0-9]*:../../devel/p5-Scalar-List-Utils
DEPENDS+=	p5-Set-IntSpan>=1.11:../../devel/p5-Set-IntSpan
DEPENDS+=	p5-Statistics-Basic-[0-9]*:../../math/p5-Statistics-Basic
DEPENDS+=	p5-Text-Balanced-[0-9]*:../../textproc/p5-Text-Balanced
DEPENDS+=	p5-Text-Format-[0-9]*:../../textproc/p5-Text-Format

.include "cf-files.mk"

PKG_SYSCONFSUBDIR=	${PKGBASE}
OWN_DIRS+=		${PKG_SYSCONFDIR}/tracks
AUTO_MKDIRS=		yes
INSTALLATION_DIRS+=	bin share/${PKGBASE} share/examples/${PKGBASE}
INSTALLATION_DIRS+=	share/doc/${PKGBASE}
INSTALLATION_DIRS+=	${PERL5_SUB_INSTALLVENDORLIB}/Circos
INSTALLATION_DIRS+=	${EGDIR}/etc ${EGDIR}/example/etc ${EGDIR}/etc/tracks
EGDIR=			share/examples/${PKGBASE}

.for file in ${CF_FILES}
CONF_FILES+=		${EGDIR}/${file} ${PKG_SYSCONFDIR}/${file:C/.*etc\///}
.endfor

SUBST_CLASSES+=		paths
SUBST_NOOP_OK.paths=	yes
SUBST_STAGE.paths=	do-configure
SUBST_FILES.paths=	bin/circos lib/Circos/Error.pm lib/Circos/Configuration.pm
SUBST_FILES.paths+=	${CF_FILES}
SUBST_SED.paths=	-e 's|<<include etc/\(.*\)>>|<<include \1>>|g'
SUBST_SED.paths+=	-e 's|etc/tracks|tracks|g'
SUBST_SED.paths+=	-e 's|data/|${PREFIX}/share/${PKGBASE}/data/|g'
SUBST_SED.paths+=	-e 's|error/|${PREFIX}/share/${PKGBASE}/error/|g'
SUBST_SED.paths+=	-e 's|fonts/|${PREFIX}/share/${PKGBASE}/fonts/|g'
SUBST_SED.paths+=	-e 's|tiles/|${PREFIX}/share/${PKGBASE}/tiles/|g'
SUBST_SED.paths+=	-e 's|@PREFIX@|${PREFIX}|g'
SUBST_SED.paths+=	-e 's|@PKG_SYSCONFDIR@|${PKG_SYSCONFDIR}|g'

REPLACE_PERL+=	bin/gddiag bin/circos etc/makehuesteps

REPLACE_BASH+=	data/karyotype/parse.karyotype data/karyotype/assembly/parse.assembly

pre-install:
	cd ${WRKSRC} && rm -f bin/*.orig lib/Circos/*.pm.orig

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
	for file in ${CF_FILES}; do					\
	  ${INSTALL_DATA} ${WRKSRC}/$${file} ${DESTDIR}${PREFIX}/${EGDIR}/$${file} ; \
	done;								\
	pax -rw -pp data error fonts tiles ${DESTDIR}${PREFIX}/share/${PKGBASE};	\
	cd etc && pax -rw -pp . ${DESTDIR}${PREFIX}/${EGDIR};		\
	cd ../lib/Circos && pax -rw -pp . ${DESTDIR}${PREFIX}/${PERL5_SUB_INSTALLVENDORLIB}/Circos

gen-cf-files: .PHONY
	{ \
	${ECHO} '# $$''NetBSD$$'; \
	${ECHO} '#'; \
	(cd ${WRKSRC} && find . -name '*.conf' | sed -e 's|^\.\/||' | sort) \
	| ${AWK} '!/\.orig$$/ { print "CF_FILES+=\t" $$0 }'; \
	} >cf-files.mk

.include "../../mk/bsd.pkg.mk"
