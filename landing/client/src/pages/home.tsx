import { motion, useScroll, useTransform } from "framer-motion";
import { useRef } from "react";
import { Button } from "@/components/ui/button";
import {
  Smartphone,
  Monitor,
  Tablet,
  Target,
  Cloud,
  Shield,
  Timer,
  BarChart3,
  Calendar,
  CheckCircle2,
  ArrowRight,
  Play,
  Star,
  ChevronRight,
  ListTodo,
  Repeat,
  Focus
} from "lucide-react";
import phoneMockup from "@assets/generated_images/productivity_app_phone_mockup.png";
import tabletMockup from "@assets/generated_images/productivity_app_tablet_mockup.png";
import desktopMockup from "@assets/generated_images/productivity_app_desktop_mockup.png";

const fadeInUp = {
  hidden: { opacity: 0, y: 40 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.6, ease: [0.22, 1, 0.36, 1] as const } }
};

const staggerContainer = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: 0.12, delayChildren: 0.1 }
  }
};

const scaleIn = {
  hidden: { opacity: 0, scale: 0.9 },
  visible: { opacity: 1, scale: 1, transition: { duration: 0.5, ease: [0.22, 1, 0.36, 1] as const } }
};

function Navbar() {
  return (
    <motion.nav
      initial={{ y: -20, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ duration: 0.5 }}
      className="fixed top-0 left-0 right-0 z-50 px-6 py-4"
    >
      <div className="max-w-7xl mx-auto flex items-center justify-between glass rounded-2xl px-6 py-3">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-primary to-accent flex items-center justify-center">
            <Target className="w-5 h-5 text-white" />
          </div>
          <span className="font-display font-semibold text-xl" data-testid="logo-text">Quest</span>
        </div>

        <div className="hidden md:flex items-center gap-8">
          <a href="#features" className="text-sm text-muted-foreground hover:text-foreground transition-colors" data-testid="nav-features">Features</a>
          <a href="#platforms" className="text-sm text-muted-foreground hover:text-foreground transition-colors" data-testid="nav-platforms">Platforms</a>
          <a href="#testimonials" className="text-sm text-muted-foreground hover:text-foreground transition-colors" data-testid="nav-testimonials">Testimonials</a>
          <a href="#pricing" className="text-sm text-muted-foreground hover:text-foreground transition-colors" data-testid="nav-pricing">Pricing</a>
        </div>

        <div className="flex items-center gap-3">
          <Button asChild size="sm" className="bg-gradient-to-r from-primary to-accent hover:opacity-90 transition-opacity" data-testid="button-getstarted">
            <a href="https://boomsupersonic.quest/" target="_blank" rel="noopener noreferrer">Get Started</a>
          </Button>
        </div>
      </div>
    </motion.nav>
  );
}

function Hero() {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start start", "end start"]
  });

  const y = useTransform(scrollYProgress, [0, 1], [0, 100]);
  const opacity = useTransform(scrollYProgress, [0, 0.8], [1, 0]);

  return (
    <section ref={ref} className="relative min-h-[70vh] pt-32 pb-10 overflow-hidden noise">
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-1/4 left-1/4 w-[600px] h-[600px] bg-primary/20 rounded-full blur-[120px]" />
        <div className="absolute bottom-1/4 right-1/4 w-[500px] h-[500px] bg-accent/20 rounded-full blur-[120px]" />
      </div>

      <motion.div
        style={{ y, opacity }}
        className="relative z-10 max-w-7xl mx-auto px-6"
      >
        <motion.div
          variants={staggerContainer}
          initial="hidden"
          animate="visible"
          className="text-center max-w-4xl mx-auto"
        >
          <motion.div variants={fadeInUp} className="mb-6">
            <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full glass text-sm font-medium">
              <span className="w-2 h-2 rounded-full bg-green-500 animate-pulse" />
              Now available on all platforms
            </span>
          </motion.div>

          <motion.h1
            variants={fadeInUp}
            className="font-display text-5xl md:text-7xl lg:text-8xl font-bold tracking-tight mb-6"
          >
            Master your day,
            <br />
            <span className="gradient-text">achieve your goals</span>
          </motion.h1>

          <motion.p
            variants={fadeInUp}
            className="text-lg md:text-xl text-muted-foreground max-w-2xl mx-auto mb-10"
          >
            The all-in-one productivity app with tasks, habits, and focus timer.
            Build better habits, stay focused, and accomplish more — all in one beautiful app.
          </motion.p>

          <motion.div variants={fadeInUp} className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <Button
              asChild
              size="lg"
              className="bg-gradient-to-r from-primary to-accent hover:opacity-90 transition-all text-lg px-8 py-6 glow-primary"
              data-testid="button-liveapp"
            >
              <a href="https://boomsupersonic.quest/" target="_blank" rel="noopener noreferrer">
                Try Live App
                <ArrowRight className="ml-2 w-5 h-5" />
              </a>
            </Button>
            <Button
              size="lg"
              variant="outline"
              className="text-lg px-8 py-6 border-border/50 hover:bg-card"
              data-testid="button-watchdemo"
            >
              <Play className="mr-2 w-5 h-5" />
              Watch Demo
            </Button>
          </motion.div>

          <motion.div variants={fadeInUp} className="mt-8">
            <p className="text-sm text-muted-foreground mb-4">Download for your platform</p>
            <div className="flex flex-wrap items-center justify-center gap-3">
              <a
                href="#"
                className="flex items-center gap-2 px-5 py-3 rounded-xl glass hover:bg-white/10 transition-colors group"
                data-testid="link-appstore"
              >
                <svg className="w-6 h-6" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
                </svg>
                <div className="text-left">
                  <p className="text-[10px] text-muted-foreground leading-none">Download on the</p>
                  <p className="font-semibold text-sm">App Store</p>
                </div>
              </a>

              <a
                href="#"
                className="flex items-center gap-2 px-5 py-3 rounded-xl glass hover:bg-white/10 transition-colors group"
                data-testid="link-playstore"
              >
                <svg className="w-6 h-6" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M3,20.5V3.5C3,2.91 3.34,2.39 3.84,2.15L13.69,12L3.84,21.85C3.34,21.6 3,21.09 3,20.5M16.81,15.12L6.05,21.34L14.54,12.85L16.81,15.12M20.16,10.81C20.5,11.08 20.75,11.5 20.75,12C20.75,12.5 20.53,12.9 20.18,13.18L17.89,14.5L15.39,12L17.89,9.5L20.16,10.81M6.05,2.66L16.81,8.88L14.54,11.15L6.05,2.66Z" />
                </svg>
                <div className="text-left">
                  <p className="text-[10px] text-muted-foreground leading-none">Get it on</p>
                  <p className="font-semibold text-sm">Google Play</p>
                </div>
              </a>

              <a
                href="#"
                className="flex items-center gap-2 px-5 py-3 rounded-xl glass hover:bg-white/10 transition-colors group"
                data-testid="link-windows"
              >
                <svg className="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M3,12V6.75L9,5.43V11.91L3,12M20,3V11.75L10,11.9V5.21L20,3M3,13L9,13.09V19.9L3,18.75V13M20,13.25V22L10,20.09V13.1L20,13.25Z" />
                </svg>
                <div className="text-left">
                  <p className="text-[10px] text-muted-foreground leading-none">Download for</p>
                  <p className="font-semibold text-sm">Windows</p>
                </div>
              </a>

              <a
                href="#"
                className="flex items-center gap-2 px-5 py-3 rounded-xl glass hover:bg-white/10 transition-colors group"
                data-testid="link-macos"
              >
                <svg className="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
                </svg>
                <div className="text-left">
                  <p className="text-[10px] text-muted-foreground leading-none">Download for</p>
                  <p className="font-semibold text-sm">macOS</p>
                </div>
              </a>

              <a
                href="#"
                className="flex items-center gap-2 px-5 py-3 rounded-xl glass hover:bg-white/10 transition-colors group"
                data-testid="link-linux"
              >
                <svg className="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M14.62,8.35C14.2,8.63 12.87,9.39 12.67,9.54C12.28,9.85 11.92,9.83 11.53,9.53C11.33,9.37 10,8.61 9.58,8.34C9.1,8.03 9.13,7.64 9.66,7.42C11.3,6.73 12.94,6.78 14.57,7.45C15.06,7.66 15.08,8.05 14.62,8.35M21.84,15.63C20.91,13.54 19.64,11.64 18,9.97C17.47,9.42 17.14,8.8 16.94,8.09C16.84,7.76 16.77,7.42 16.7,7.08C16.5,6.2 16.41,5.3 16,4.47C15.27,2.89 14,2.07 12.16,2C10.35,2.05 9.1,2.85 8.43,4.38C8,5.22 7.91,6.1 7.72,6.97C7.63,7.38 7.53,7.79 7.37,8.18C7.1,8.83 6.7,9.41 6.2,9.91C4.5,11.54 3.17,13.42 2.21,15.54C1.5,17.12 1.72,18.62 2.9,19.93C4.04,21.18 5.5,21.81 7.15,21.95C8.31,22.05 9.47,22 10.63,22C10.94,22 11.26,22 11.57,22C12.31,21.97 13.05,22 13.79,21.97C14.94,21.92 16.09,21.97 17.23,21.85C18.74,21.71 20.07,21.17 21.13,20.06C22.26,18.87 22.5,17.43 21.84,15.63M11.71,15.23C11.24,15.5 10.57,15.58 10,15.38C9.5,15.18 9.13,14.77 8.95,14.26C8.5,12.95 9.14,11.58 10.45,11.15C11.26,10.88 12.13,11.07 12.72,11.63C13.69,12.53 13.41,14.25 11.71,15.23M15.5,14.26C15.33,14.77 14.96,15.18 14.46,15.38C13.89,15.58 13.22,15.5 12.75,15.23C11.05,14.25 10.77,12.53 11.74,11.63C12.33,11.07 13.2,10.88 14,11.15C15.32,11.58 15.96,12.95 15.5,14.26Z" />
                </svg>
                <div className="text-left">
                  <p className="text-[10px] text-muted-foreground leading-none">Download for</p>
                  <p className="font-semibold text-sm">Linux</p>
                </div>
              </a>
            </div>
          </motion.div>

          <motion.div variants={fadeInUp} className="mt-12 flex items-center justify-center gap-6 text-sm text-muted-foreground">
            <div className="flex items-center gap-2">
              <CheckCircle2 className="w-4 h-4 text-green-500" />
              Free forever plan
            </div>
            <div className="flex items-center gap-2">
              <CheckCircle2 className="w-4 h-4 text-green-500" />
              No credit card required
            </div>
            <div className="flex items-center gap-2">
              <CheckCircle2 className="w-4 h-4 text-green-500" />
              Cancel anytime
            </div>
          </motion.div>
        </motion.div>
      </motion.div>
    </section>
  );
}

function AppShowcase() {
  return (
    <section className="relative py-16 overflow-hidden noise">
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-0 left-1/3 w-[500px] h-[500px] bg-primary/20 rounded-full blur-[120px]" />
        <div className="absolute bottom-0 right-1/3 w-[400px] h-[400px] bg-accent/20 rounded-full blur-[100px]" />
      </div>

      <motion.div
        initial={{ opacity: 0, y: 40 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true, margin: "-100px" }}
        transition={{ duration: 0.8, ease: [0.22, 1, 0.36, 1] }}
        className="relative z-10 max-w-7xl mx-auto px-6"
      >
        <div className="flex items-end justify-center gap-4 md:gap-8">
          <motion.div
            className="floating-delayed hidden md:block"
            whileHover={{ scale: 1.02, y: -10 }}
            transition={{ type: "spring", stiffness: 300 }}
          >
            <img
              src={tabletMockup}
              alt="Quest on tablet"
              className="w-64 lg:w-80 rounded-2xl shadow-2xl glow-accent"
              data-testid="img-tablet-mockup"
            />
          </motion.div>

          <motion.div
            className="floating"
            whileHover={{ scale: 1.02, y: -10 }}
            transition={{ type: "spring", stiffness: 300 }}
          >
            <img
              src={phoneMockup}
              alt="Quest on mobile"
              className="w-48 md:w-56 lg:w-64 rounded-3xl shadow-2xl glow-primary"
              data-testid="img-phone-mockup"
            />
          </motion.div>

          <motion.div
            className="floating-slow hidden md:block"
            whileHover={{ scale: 1.02, y: -10 }}
            transition={{ type: "spring", stiffness: 300 }}
          >
            <img
              src={desktopMockup}
              alt="Quest on desktop"
              className="w-72 lg:w-96 rounded-2xl shadow-2xl glow-primary"
              data-testid="img-desktop-mockup"
            />
          </motion.div>
        </div>
      </motion.div>
    </section>
  );
}


const features = [
  {
    icon: ListTodo,
    title: "Smart Tasks",
    description: "Organize your tasks with subtasks, priorities, and due dates. Stay on top of everything."
  },
  {
    icon: Repeat,
    title: "Habit Tracking",
    description: "Build positive habits with streak tracking, flexible schedules, and progress insights."
  },
  {
    icon: Timer,
    title: "Focus Timer",
    description: "Stay productive with Pomodoro-style focus sessions and break reminders."
  },
  {
    icon: BarChart3,
    title: "Smart Analytics",
    description: "Gain insights into your productivity patterns with beautiful charts and reports."
  },
  {
    icon: Cloud,
    title: "Cross-Platform Sync",
    description: "Your data syncs seamlessly across all devices. Start on your phone, continue on desktop."
  },
  {
    icon: Target,
    title: "Goal Achievement",
    description: "Built with Flutter for native performance on every platform. Beautiful and fast."
  }
];

function Features() {
  return (
    <section id="features" className="py-32 relative">
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-1/2 left-0 w-[400px] h-[400px] bg-primary/10 rounded-full blur-[100px]" />
      </div>

      <div className="max-w-7xl mx-auto px-6 relative z-10">
        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-100px" }}
          variants={staggerContainer}
          className="text-center mb-16"
        >
          <motion.span variants={fadeInUp} className="text-primary font-medium mb-4 block">
            FEATURES
          </motion.span>
          <motion.h2 variants={fadeInUp} className="font-display text-4xl md:text-5xl font-bold mb-6">
            Everything you need to
            <br />
            <span className="gradient-text">stay productive</span>
          </motion.h2>
          <motion.p variants={fadeInUp} className="text-muted-foreground text-lg max-w-2xl mx-auto">
            Packed with powerful features designed to help you and your team accomplish more, together.
          </motion.p>
        </motion.div>

        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-50px" }}
          variants={staggerContainer}
          className="grid md:grid-cols-2 lg:grid-cols-3 gap-6"
        >
          {features.map((feature, i) => (
            <motion.div
              key={i}
              variants={fadeInUp}
              whileHover={{ y: -5, scale: 1.02 }}
              className="group gradient-border p-6 rounded-2xl hover:glow-primary transition-all duration-300"
              data-testid={`card-feature-${i}`}
            >
              <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-primary/20 to-accent/20 flex items-center justify-center mb-4 group-hover:from-primary/30 group-hover:to-accent/30 transition-colors">
                <feature.icon className="w-6 h-6 text-primary" />
              </div>
              <h3 className="font-display font-semibold text-xl mb-2">{feature.title}</h3>
              <p className="text-muted-foreground">{feature.description}</p>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}

const platforms = [
  { icon: Smartphone, name: "iOS & Android", description: "Native mobile experience", url: null },
  { icon: Monitor, name: "Windows & Mac", description: "Full desktop power", url: null },
  { icon: Tablet, name: "Web App", description: "Access anywhere", url: "https://boomsupersonic.quest/" }
];

function Platforms() {
  return (
    <section id="platforms" className="py-32 relative overflow-hidden">
      <div className="absolute inset-0">
        <div className="absolute bottom-0 right-0 w-[500px] h-[500px] bg-accent/10 rounded-full blur-[120px]" />
      </div>

      <div className="max-w-7xl mx-auto px-6 relative z-10">
        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={staggerContainer}
          className="grid lg:grid-cols-2 gap-16 items-center"
        >
          <div>
            <motion.span variants={fadeInUp} className="text-primary font-medium mb-4 block">
              CROSS-PLATFORM
            </motion.span>
            <motion.h2 variants={fadeInUp} className="font-display text-4xl md:text-5xl font-bold mb-6">
              One app,
              <br />
              <span className="gradient-text">every device</span>
            </motion.h2>
            <motion.p variants={fadeInUp} className="text-muted-foreground text-lg mb-8">
              Built with Flutter, Quest delivers a truly native experience on every platform.
              Your productivity stays consistent whether you're on your phone, tablet, or desktop.
            </motion.p>

            <motion.div variants={staggerContainer} className="space-y-4">
              {platforms.map((platform, i) => {
                const platformContent = (
                  <>
                    <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-primary to-accent flex items-center justify-center">
                      <platform.icon className="w-6 h-6 text-white" />
                    </div>
                    <div className="flex-1">
                      <h4 className="font-semibold">{platform.name}</h4>
                      <p className="text-sm text-muted-foreground">{platform.description}</p>
                    </div>
                    <ChevronRight className="w-5 h-5 text-muted-foreground group-hover:text-primary transition-colors" />
                  </>
                );

                if (platform.url) {
                  return (
                    <motion.a
                      key={i}
                      href={platform.url}
                      target="_blank"
                      rel="noopener noreferrer"
                      variants={fadeInUp}
                      whileHover={{ x: 10 }}
                      className="flex items-center gap-4 p-4 rounded-xl glass cursor-pointer group"
                      data-testid={`platform-${i}`}
                    >
                      {platformContent}
                    </motion.a>
                  );
                }

                return (
                  <motion.div
                    key={i}
                    variants={fadeInUp}
                    whileHover={{ x: 10 }}
                    className="flex items-center gap-4 p-4 rounded-xl glass cursor-pointer group"
                    data-testid={`platform-${i}`}
                  >
                    {platformContent}
                  </motion.div>
                );
              })}
            </motion.div>
          </div>

          <motion.div
            variants={scaleIn}
            className="relative"
          >
            <div className="absolute inset-0 bg-gradient-to-r from-primary/20 to-accent/20 rounded-3xl blur-3xl" />
            <div className="relative glass rounded-3xl p-8 overflow-hidden">
              <div className="grid grid-cols-2 gap-4">
                <motion.div
                  className="floating"
                  whileHover={{ scale: 1.05 }}
                >
                  <img
                    src={phoneMockup}
                    alt="Mobile app"
                    className="rounded-2xl shadow-xl"
                  />
                </motion.div>
                <motion.div
                  className="floating-delayed"
                  whileHover={{ scale: 1.05 }}
                >
                  <img
                    src={tabletMockup}
                    alt="Tablet app"
                    className="rounded-2xl shadow-xl"
                  />
                </motion.div>
              </div>
              <motion.div
                className="mt-4 floating-slow"
                whileHover={{ scale: 1.02 }}
              >
                <img
                  src={desktopMockup}
                  alt="Desktop app"
                  className="rounded-2xl shadow-xl"
                />
              </motion.div>
            </div>
          </motion.div>
        </motion.div>
      </div>
    </section>
  );
}

const testimonials = [
  {
    quote: "Quest has completely transformed how I manage my daily tasks and habits. The focus timer keeps me productive.",
    author: "Sarah Chen",
    role: "Product Designer",
    rating: 5
  },
  {
    quote: "Finally, a productivity app that combines tasks, habits, and focus sessions. The Flutter performance is unmatched.",
    author: "Marcus Johnson",
    role: "Software Engineer",
    rating: 5
  },
  {
    quote: "The habit tracking feature helped me build a morning routine that stuck. My productivity increased by 40%.",
    author: "Elena Rodriguez",
    role: "Entrepreneur",
    rating: 5
  }
];

function Testimonials() {
  return (
    <section id="testimonials" className="py-32 relative">
      <div className="absolute inset-0">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-primary/5 rounded-full blur-[100px]" />
      </div>

      <div className="max-w-7xl mx-auto px-6 relative z-10">
        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={staggerContainer}
          className="text-center mb-16"
        >
          <motion.span variants={fadeInUp} className="text-primary font-medium mb-4 block">
            TESTIMONIALS
          </motion.span>
          <motion.h2 variants={fadeInUp} className="font-display text-4xl md:text-5xl font-bold mb-6">
            Loved by <span className="gradient-text">thousands</span>
          </motion.h2>
          <motion.p variants={fadeInUp} className="text-muted-foreground text-lg max-w-2xl mx-auto">
            Join thousands of people who have already transformed their productivity with Quest.
          </motion.p>
        </motion.div>

        <motion.div
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={staggerContainer}
          className="grid md:grid-cols-3 gap-6"
        >
          {testimonials.map((testimonial, i) => (
            <motion.div
              key={i}
              variants={fadeInUp}
              whileHover={{ y: -5 }}
              className="glass p-8 rounded-2xl"
              data-testid={`testimonial-${i}`}
            >
              <div className="flex gap-1 mb-4">
                {[...Array(testimonial.rating)].map((_, j) => (
                  <Star key={j} className="w-5 h-5 fill-yellow-500 text-yellow-500" />
                ))}
              </div>
              <p className="text-lg mb-6 leading-relaxed">"{testimonial.quote}"</p>
              <div>
                <p className="font-semibold">{testimonial.author}</p>
                <p className="text-sm text-muted-foreground">{testimonial.role}</p>
              </div>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}

function CTA() {
  return (
    <section id="pricing" className="py-32 relative">
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute bottom-0 left-1/4 w-[400px] h-[400px] bg-primary/20 rounded-full blur-[120px]" />
        <div className="absolute top-0 right-1/4 w-[300px] h-[300px] bg-accent/20 rounded-full blur-[100px]" />
      </div>

      <motion.div
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true }}
        variants={staggerContainer}
        className="max-w-4xl mx-auto px-6 relative z-10"
      >
        <motion.div
          variants={scaleIn}
          className="gradient-border rounded-3xl p-12 text-center glass"
        >
          <motion.h2 variants={fadeInUp} className="font-display text-4xl md:text-5xl font-bold mb-6">
            Ready to boost your
            <br />
            <span className="gradient-text">productivity?</span>
          </motion.h2>
          <motion.p variants={fadeInUp} className="text-muted-foreground text-lg mb-8 max-w-xl mx-auto">
            Join thousands of people who are already achieving more with Quest.
            Start free, upgrade when you're ready.
          </motion.p>

          <motion.div variants={fadeInUp} className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <Button
              asChild
              size="lg"
              className="bg-gradient-to-r from-primary to-accent hover:opacity-90 transition-all text-lg px-10 py-6 glow-primary"
              data-testid="button-cta-getstarted"
            >
              <a href="https://boomsupersonic.quest/" target="_blank" rel="noopener noreferrer">
                Get Started for Free
                <ArrowRight className="ml-2 w-5 h-5" />
              </a>
            </Button>
          </motion.div>

          <motion.p variants={fadeInUp} className="mt-6 text-sm text-muted-foreground">
            No credit card required • Free plan available forever
          </motion.p>
        </motion.div>
      </motion.div>
    </section>
  );
}

function Footer() {
  return (
    <footer className="py-12 border-t border-border/50">
      <div className="max-w-7xl mx-auto px-6">
        <div className="flex flex-col md:flex-row items-center justify-between gap-6">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-primary to-accent flex items-center justify-center">
              <Target className="w-5 h-5 text-white" />
            </div>
            <span className="font-display font-semibold text-xl">Quest</span>
          </div>

          <div className="flex items-center gap-8 text-sm text-muted-foreground">
            <a href="#" className="hover:text-foreground transition-colors" data-testid="link-privacy">Privacy</a>
            <a href="#" className="hover:text-foreground transition-colors" data-testid="link-terms">Terms</a>
            <a href="#" className="hover:text-foreground transition-colors" data-testid="link-contact">Contact</a>
            <a href="#" className="hover:text-foreground transition-colors" data-testid="link-blog">Blog</a>
          </div>

          <p className="text-sm text-muted-foreground">
            © 2026 BOOM Supersonic. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
  );
}

export default function Home() {
  return (
    <div className="min-h-screen bg-background overflow-x-hidden">
      <Navbar />
      <Hero />
      <AppShowcase />
      <Features />
      <Platforms />
      <Testimonials />
      <CTA />
      <Footer />
    </div>
  );
}
