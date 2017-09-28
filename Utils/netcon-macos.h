/**
 Get properties of network connections on macOS.
 Created by: Simon Zolin
 Copyright (c) 2017 GPL v3 http://www.gnu.org/licenses/gpl.html
 */

#ifndef netcon_macos_h
#define netcon_macos_h

#include <errno.h>
#include <sys/socketvar.h>
#include <sys/sysctl.h>
#include <netinet/in.h>
#include <netinet/in_pcb.h>


/* Buffer format:
 (struct xinpgen) (struct xgen_n)...
 */

/** Get properties of all TCP connections.
 Return number of bytes written;  0 on error;  <0 if not enough space. */
static inline int net_pcblist(char *buf, size_t cap, uint flags)
{
    size_t n;
    const char *name = "net.inet.tcp.pcblist_n";
    
    n = cap;
    if (0 != sysctlbyname(name, buf, &n, 0, 0)) {
        if (errno == ENOMEM)
            return -(int)n;
        return 0;
    }
    
    if (n > cap / 2 || cap < 1024) {
        /*
         Note: sysctlbyname() should return with ENOMEM when there's not enough space in buffer,
         but it doesn't (OS v10.12.4).
         If output buffer is filled by more than a half, we need a larger buffer to ensure no data is lost.
         Also, prevent user from using too small buffer, otherwise the previous assumption won't work. */
        if (0 != sysctlbyname(name, NULL, &n, 0, 0))
            return 0;
        return -(int)((n * 2) | 1024);
    }
    
    return (int)n;
}

enum xgn_kind {
    XSO_SOCKET = 0x001, //struct xsocket_n
    XSO_INPCB = 0x010, //struct xinpcb_n
};

/* inet.c, (c) Apple Inc. */
struct xgen_n {
    u_int32_t    xgn_len;            /* length of this structure */
    u_int32_t    xgn_kind;        /* number of PCBs at this time */
};

#define ROUNDUP64(n) \
(1 + (((n) - 1) | (sizeof(uint64_t) - 1)))

/** Get the first object.
 Return NULL on error. */
static inline struct xinpgen* net_pcblist_first(char **ptr, const char *end)
{
    struct xinpgen *xg = (void*)*ptr;
    if (*ptr + sizeof(struct xinpgen) >= end
        || xg->xig_len < sizeof(struct xinpgen)
        || *ptr + ROUNDUP64(xg->xig_len) > end)
        return NULL;
    *ptr += ROUNDUP64(xg->xig_len);
    return xg;
}

/** Get the next object from list.
 The returned object should be casted to the type specified by 'xgn_kind' field.
 Return NULL if no more items. */
static inline struct xgen_n* net_pcblist_next(char **ptr, const char *end)
{
    struct xgen_n *xn = (void*)*ptr;
    if (*ptr + sizeof(struct xgen_n) >= end
        || xn->xgn_len < sizeof(struct xgen_n)
        || *ptr + ROUNDUP64(xn->xgn_len) > end)
        return NULL;
    *ptr += ROUNDUP64(xn->xgn_len);
    return xn;
}

/* inet.c, (c) Apple Inc. */
struct xinpcb_n {
    u_int32_t               xi_len;         /* length of this structure */
    u_int32_t               xi_kind;                /* XSO_INPCB */
    u_int64_t               xi_inpp;
    u_short                 inp_fport;      /* foreign port */
    u_short                 inp_lport;      /* local port */
    u_int64_t               inp_ppcb;       /* pointer to per-protocol pcb */
    inp_gen_t               inp_gencnt;     /* generation count of this instance */
    int                             inp_flags;      /* generic IP/datagram flags */
    u_int32_t               inp_flow;
    u_char                  inp_vflag;
    u_char                  inp_ip_ttl;     /* time to live */
    u_char                  inp_ip_p;       /* protocol */
    union {                                 /* foreign host table entry */
        struct  in_addr_4in6    inp46_foreign;
        struct  in6_addr        inp6_foreign;
    }                               inp_dependfaddr;
    union {                                 /* local host table entry */
        struct  in_addr_4in6    inp46_local;
        struct  in6_addr        inp6_local;
    }                               inp_dependladdr;
    struct {
        u_char          inp4_ip_tos;    /* type of service */
    }                               inp_depend4;
    struct {
        u_int8_t        inp6_hlim;
        int                     inp6_cksum;
        u_short         inp6_ifindex;
        short           inp6_hops;
    }                               inp_depend6;
    u_int32_t               inp_flowhash;
};

#define xinp_ip4_local(inp) \
(&(inp)->inp_dependladdr.inp46_local.ia46_pad32[2])

#define xinp_ip4_remote(inp) \
(&(inp)->inp_dependfaddr.inp46_foreign.ia46_pad32[2])

/* inet.c, (c) Apple Inc. */
struct xsocket_n {
    u_int32_t        xso_len;        /* length of this structure */
    u_int32_t        xso_kind;        /* XSO_SOCKET */
    u_int64_t        xso_so;    /* makes a convenient handle */
    short            so_type;
    u_int32_t        so_options;
    short            so_linger;
    short            so_state;
    u_int64_t        so_pcb;        /* another convenient handle */
    int                xso_protocol;
    int                xso_family;
    short            so_qlen;
    short            so_incqlen;
    short            so_qlimit;
    short            so_timeo;
    u_short            so_error;
    pid_t            so_pgid;
    u_int32_t        so_oobmark;
    uid_t            so_uid;        /* XXX */
};

#endif /* netcon_macos_h */
