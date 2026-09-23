import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Agency — Ownership for Creators, Builders & Educators",
  description: "The permissionless launchpad where people launch tokens that create real ownership, skills, and tools. Arc-first. Privy wallets.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="bg-black text-white antialiased">{children}</body>
    </html>
  );
}
